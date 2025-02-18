--------------------------------------------------------------------------------
-- FILE   : cubedos-generic_message_manager.adb
-- SUBJECT: Body of a package for message passing in CubedOS.
-- AUTHOR : (C) Copyright 2022 by Vermont Technical College
--
--------------------------------------------------------------------------------
pragma SPARK_Mode (On);

with CubedOS.Message_Types.Message_Queues; use CubedOS.Message_Types.Message_Queues;
with Domain_Config;

package body CubedOS.Generic_Message_Manager with
Refined_State => (Mailboxes => Message_Storage,
                  Lock => Init_Lock,
                  Request_ID_Generator => Request_ID_Gen)
is

   -- A protected object for generating request ID values.
   protected Request_ID_Gen is
      procedure Generate_Next_ID (Request_ID : out Request_ID_Type);
   private
      Next_Request_ID : Request_ID_Type := 1;
   end Request_ID_Gen;

   type Module_Index is new Positive range 1 .. Module_Count;
   type Module_Init_List is array (Module_Index) of Boolean
     with Default_Component_Value => False;
   type Module_Init_List_Owner is access Module_Init_List;

   protected Init_Lock is
      function Is_Locked return Boolean;
      function Is_Initialized(Module_ID : Module_ID_Type) return Boolean
        with Pre => Has_Module(This_Domain, Module_ID);
      entry Wait;
      procedure Unlock (Module : Module_ID_Type)
        with Pre => Has_Module(This_Domain, Module);
      procedure Unlock_Manual
        with Post => not Is_Locked;
   private
      Inited : Module_Init_List_Owner;
      Locked : Boolean := True;
   end Init_Lock;

   type Message_Queue_Owner is access Message_Queues.Bounded_queue;

   subtype Message_Count_Type is Natural;

   -- A protected type for holding messages.
   protected type Sync_Mailbox is

      -- Deposit the given message into THIS mailbox. This procedure returns at once without waiting for the
      -- message to be received. If the mailbox is full the returned status indicates this.
      procedure Send
        (Message : in out Msg_Owner; Status : out Status_Type)
        with Pre => Message /= null and then Payload(Message.all) /= null,
        Post => Message = null;

      -- Send the indicated message. This procedure returns at once without waiting for the
      -- message to be received. If the mailbox is full the message is lost.
      procedure Unchecked_Send (Message : in out Msg_Owner)
        with Pre => Message /= null and then Payload(Message.all) /= null,
        Post => Message = null;

      -- Returns the number of messages in the mailbox.
      function Message_Count return Message_Count_Type;

      -- Receive a message. This entry waits indefinitely for a message to be available.
      entry Receive (Message : out Message_Record);
        --with Post => Is_Valid(Message);

      -- Set the mailbox size and metadata
      procedure Initialize (Spec : Module_Metadata; Size : in Positive)
        with Pre => Size < Natural'Last - 1;

   private
      Q : Message_Queue_Owner := null;
      Metadata : Module_Metadata := (1, Empty_Type_Array'Access);
      Message_Waiting : Boolean := False;
   end Sync_Mailbox;

   -- One mailbox for each module.
   Message_Storage : array (Module_Index) of Sync_Mailbox;

   function Messaging_Ready return Boolean
   is (not Init_Lock.Is_Locked)
     with SPARK_Mode => Off,
     -- We hide this from SPARK because Init_Lock.Is_Locked doesn't have
     -- any meaningful interferences.
     Refined_Post => Messaging_Ready'Result = not Init_Lock.Is_Locked;

   procedure Skip_Mailbox_Initialization is
   begin
      Init_Lock.Unlock_Manual;
      pragma Assert(Messaging_Ready);
   end Skip_Mailbox_Initialization;


   ------------------
   -- Implementations
   ------------------

   -- A bijective function from Module_IDs inside this domain to their index
   -- in arrays. In a normal programming language we would be using a map instead
   -- of this.
   function Index_Of(Module_ID : Module_ID_Type) return Module_Index
     with Pre => Has_Module(This_Domain, Module_ID)
   is
      Index : Module_Index;
   begin
      -- Get index of given module
      for I in 1 .. Module_Count loop
         if This_Domain.Module_IDs(I) = Module_ID then
            Index := Module_Index(I);
            exit;
         end if;
      end loop;

      -- The loop is guaranteed to find an index because
      -- of the precondition that the module id must be
      -- in the domain.
      -- TODO: Prove this to spark with lemmas
      return Index;
   end Index_Of;

   protected body Request_ID_Gen is

      procedure Generate_Next_ID (Request_ID : out Request_ID_Type) is
      begin
         Request_ID      := Next_Request_ID;
         Next_Request_ID := Next_Request_ID + 1;
      end Generate_Next_ID;

   end Request_ID_Gen;

   protected body Init_Lock is
      function Is_Locked return Boolean
        is (Locked);
      function Is_Initialized(Module_ID : Module_ID_Type) return Boolean is
         Index : constant Module_Index := Index_Of(Module_ID);
      begin
         if Inited = null then
            -- Exactly zero modules are currently registered
            return False;
         end if;

         return Inited(Index);
      end Is_Initialized;

      entry Wait when not Locked is
      begin
         null;
      end Wait;

      procedure Unlock (Module : Module_ID_Type) is
         Index : constant Module_Index := Index_Of(Module);
      begin
         if Inited = null then
            Inited := new Module_Init_List;
         end if;

         -- The loop is guaranteed to find an index because
         -- of the precondition that the module id must be
         -- in the domain.
         -- TODO: prove this to spark with lemmas
         Inited(Index) := True;

         if (for all I of Inited.all => I) then
            Debugger.On_Message_System_Initialization_Complete;
            Locked := False;
         end if;
      end Unlock;
      procedure Unlock_Manual is
      begin
         Debugger.On_Message_System_Initialization_Complete;
         Locked := False;
      end Unlock_Manual;
   end Init_Lock;

   protected body Sync_Mailbox is

      procedure Send (Message : in out Msg_Owner; Status : out Status_Type) is
      begin
         if Q = null or else Is_Full(Q.all) then
            Debugger.On_Message_Receive_Failed(Message.all, Mailbox_Full_Or_Unitialized);
            Status := Mailbox_Full;
            Delete(Message);
            Message := null;
         elsif not Receives(Metadata, Message_Type(Message)) then
            Debugger.On_Message_Receive_Failed(Message.all, Rejected_Type);
            Status := Rejected_Type;
            Delete(Message);
            Message := null;
         else
            Debugger.On_Message_Receive_Succeed(Message.all);
            Put(Q.all, Message);
            Message_Waiting := True;
            Status          := Accepted;
            Message := null;
         end if;
         pragma Unused(Message);
      end Send;

      procedure Unchecked_Send (Message : in out Msg_Owner) is
      begin
         if Q = null or else Is_Full(Q.all) then
            Debugger.On_Message_Receive_Failed(Message.all, Mailbox_Full_Or_Unitialized);
            Delete(Message);
            Message := null;
         elsif not Receives(Metadata, Message_Type(Message)) then
            Debugger.On_Message_Receive_Failed(Message.all, Rejected_Type);
            Delete(Message);
            Message := null;
         else
            Debugger.On_Message_Receive_Succeed(Message.all);
            Put(Q.all, Message);
            Message_Waiting := True;
         end if;

         pragma Unused(Message);
      end Unchecked_Send;

      function Message_Count return Message_Count_Type is
      begin
         if Q = null then
            return 0;
         else
            return Count(Q.all);
         end if;
      end Message_Count;

      entry Receive (Message : out Message_Record) when Message_Waiting is
         Ptr : Msg_Owner;
      begin
         pragma Assume(if Message_Waiting then Q /= null);
         pragma Assume(if Message_Waiting then not Is_Empty(Q.all));

         Next(Q.all, Ptr);
         pragma Assume(Payload(Ptr) /= null);
         Copy(Ptr.all, Message);
         Delete(Ptr);
         pragma Unused(Ptr);

         if Is_Empty(Q.all) then
            Message_Waiting := False;
         end if;
      end Receive;

      procedure Initialize (Spec : Module_Metadata; Size : in Positive) is
      begin
         if Q = null then
            Q := new Message_Queues.Bounded_Queue'(Make(Size));
            Metadata := Spec;
         end if;
      end Initialize;

   end Sync_Mailbox;

   procedure Get_Next_Request_ID (Request_ID : out Request_ID_Type) is
   begin
      Request_ID_Gen.Generate_Next_ID (Request_ID);
   end Get_Next_Request_ID;

   function Receives(Receiver : Module_Mailbox; Msg_Type : Universal_Message_Type) return Boolean
     is (Receives(Spec(Receiver), Msg_Type));

   procedure Route_Message
     (Message : in out Msg_Owner; Status : out Status_Type)
     with
       Pre => Message /= null
       and then Payload(Message) /= null
       and then Messaging_Ready,
       Post => Message = null
   is
      Dest_Module_ID : constant Module_ID_Type := Receiver_Address(Message).Module_ID;
   begin
      if Receiver_Address(Message).Domain_ID /= Domain_ID then
         Status := Unavailable;
         Debugger.On_Message_Sent_Debug(Message.all);
         Domain_Config.Send_Outgoing_Message(Message);
      else
         if Has_Module(This_Domain, Dest_Module_ID) then
            Debugger.On_Message_Sent_Debug(Message.all);
            Message_Storage (Index_Of(Dest_Module_ID)).Send
              (Message, Status);
         else
            Debugger.On_Message_Discarded(Message.all, Destination_Doesnt_Exist);
            Status := Unavailable;
            Delete(Message);
         end if;
      end if;
   end Route_Message;

   procedure Route_Message (Message : in out Msg_Owner)
     with
       Pre => Message /= null
       and then Payload(Message) /= null
       and then Messaging_Ready,
       Post => Message = null
   is
   begin
      Debugger.On_Message_Sent_Debug(Message.all);
      if Receiver_Address(Message).Domain_ID /= Domain_ID then
         Domain_Config.Send_Outgoing_Message(Message);
      else
         if Has_Module(This_Domain, Receiver_Address(Message).Module_ID) then
            Message_Storage (Index_Of(Receiver_Address(Message).Module_ID)).Unchecked_Send
              (Message);
         else
            Debugger.On_Message_Discarded(Message.all, Destination_Doesnt_Exist);
            Delete(Message);
         end if;
         pragma Unused(Message);
      end if;
   end Route_Message;

   procedure Route_Message (Message : in Message_Record) is
      Ptr : Msg_Owner := Copy(Message);
   begin
      Route_Message (Ptr);
      pragma Unused(Ptr);
   end Route_Message;

   procedure Route_Message
     (Message : in Message_Record; Status : out Status_Type)
   is
      Ptr : Msg_Owner := Copy(Message);
   begin
      Route_Message (Ptr, Status);
      pragma Unused(Ptr);
   end Route_Message;

   procedure Wait is
   begin
      Init_Lock.Wait;
      pragma Assert(Messaging_Ready);
   end Wait;

   -------------
   -- Mailbox
   -------------

   procedure Send_Message(Box : Module_Mailbox;
                          Msg : in out Message_Record;
                          Target_Module : Module_Metadata;
                          Target_Domain : Domain_Metadata := This_Domain;
                          Status : out Status_Type)
   is
      Ptr : Msg_Owner;
   begin
      Move(Msg, Ptr);
      Route_Message (Ptr, Status);
      pragma Unreferenced(Box, Target_Module, Target_Domain);
      pragma Unused(Ptr);
   end Send_Message;

   procedure Send_Message (Box : Module_Mailbox; Msg : in out Message_Record)
   is
      Ptr : Msg_Owner;
   begin
      Move(Msg, Ptr);
      Route_Message (Ptr);
      pragma Unreferenced(Box);
      pragma Unused(Ptr);
   end Send_Message;

   procedure Send_Message
     (Box : Module_Mailbox; Msg : in out Message_Record; Status : out Status_Type)
   is
      Ptr : Msg_Owner;
   begin
      Move(Msg, Ptr);
      Route_Message (Ptr, Status);
      pragma Unreferenced(Box);
      pragma Unused(Ptr);
   end Send_Message;

   procedure Read_Next (Box : Module_Mailbox; Msg : out Message_Record) is
      Result : Message_Record;
   begin
      Message_Storage (Index_Of(Box.Module_ID)).Receive (Result);

      -- Don't allow a mailbox to read a message it can't receive.
      while not Receives(Spec(Box), Message_Type(Result)) or Payload(Result) = null loop
         Debugger.On_Message_Discarded(Result, Destination_Doesnt_Accept_Message_Type);
         if Payload(Result) /= null then
            Delete(Result);
         end if;
         pragma Loop_Invariant(Payload(Result) = null);

         pragma Assert(Has_Module(This_Domain, Box.Module_ID));
         Message_Storage (Index_Of(Box.Module_ID)).Receive (Result);
      end loop;
      Debugger.On_Message_Read(Spec(Box), Result);
      pragma Assert(Receives(Spec(Box), Message_Type(Result)));
      Msg := Result;
      pragma Assert(Receives(Spec(Box), Message_Type(Msg)));
   end Read_Next;

   procedure Pending_Messages(Box : Module_Mailbox; Size : out Natural) is
   begin
      Size := Message_Storage (Index_Of(Module_ID(Box))).Message_Count;
   end Pending_Messages;

   function Module_Registered(Module_ID : in Module_ID_Type) return Boolean
   is (Init_Lock.Is_Initialized(Module_ID))
     with SPARK_Mode => Off;
     -- Lying to SPARK because this has no meaningful interferences

   procedure Register_Module(Mailbox : in Module_Mailbox;
                             Msg_Queue_Size : in Positive)
   is
   begin
      -- Create a new mailbox for the ID
      Message_Storage (Index_Of(Module_ID(Mailbox))).Initialize (Spec(Mailbox), Msg_Queue_Size);

      Init_Lock.Unlock(Module_ID(Mailbox));
      pragma Assert(Module_Registered(Module_ID(Mailbox)));
   end Register_Module;

   -- Gives a message received from a foreign domain to the message system.
   procedure Handle_Received(Msg : in out Msg_Owner) is
   begin
      Debugger.On_Foreign_Message_Received(Msg.all);
      Route_Message(Msg);
   end Handle_Received;

begin
   pragma Assert(for all ID of This_Domain.Module_IDs => not Module_Registered(ID));
end CubedOS.Generic_Message_Manager;
