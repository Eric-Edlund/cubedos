--------------------------------------------------------------------------------
-- FILE   : cubedos-interpreter-api.ads
-- SUBJECT: Specification of a package that defines the CubedOS.Interpreter API
-- AUTHOR : (C) Copyright 2021 by Vermont Technical College
--
-- All the subprograms in this package are task safe.
--
-- THIS FILE WAS GENERATED BY Merc. DO NOT EDIT!!
--------------------------------------------------------------------------------
pragma SPARK_Mode(On);
pragma Warnings(Off);

with Name_Resolver;
with CubedOS.Lib; use CubedOS.Lib;
with Message_Manager;  use Message_Manager;
with CubedOS.Message_Types; use CubedOS.Message_Types;
with System;
with CubedOS.Lib.XDR; use CubedOS.Lib.XDR;
with Ada.Unchecked_Deallocation;


package CubedOS.Interpreter.API is

   pragma Elaborate_Body;
   type Octet_Array_Ptr is access CubedOS.Lib.Octet_Array;
   type String_Ptr is access String;
   
   This_Module : constant Module_ID_Type := Name_Resolver.Interpreter;
   
   type Message_Type is
      (Set_Reply, 
      Add_Request, 
      Clear_Request, 
      Add_Reply, 
      Set_Request);

   Set_Reply_Msg : constant Universal_Message_Type := (This_Module, Message_Type'Pos(Set_Reply));
   Add_Request_Msg : constant Universal_Message_Type := (This_Module, Message_Type'Pos(Add_Request));
   Clear_Request_Msg : constant Universal_Message_Type := (This_Module, Message_Type'Pos(Clear_Request));
   Add_Reply_Msg : constant Universal_Message_Type := (This_Module, Message_Type'Pos(Add_Reply));
   Set_Request_Msg : constant Universal_Message_Type := (This_Module, Message_Type'Pos(Set_Request));
   
   This_Receives : aliased constant Message_Type_Array := (
   Add_Request_Msg,
   Clear_Request_Msg,
   Set_Request_Msg);
   Mail_Target : aliased constant Module_Metadata := Define_Module(This_Module, This_Receives'Access);
   
   procedure Clear_Request_Encode
      (Receiver_Address : in Message_Address;
      Sender_Address : in Message_Address;
      Request_ID : in Request_ID_Type;
      Priority : in System.Priority := System.Default_Priority;
      Result : out  Message_Record)
   with
      Pre => true
         and then Receiver_Address.Module_ID = This_Module,
      Post => CubedOS.Message_Types.Message_Type(Result) = Clear_Request_Msg
         and CubedOS.Message_Types.Sender_Address(Result) = Sender_Address
         and CubedOS.Message_Types.Receiver_Address(Result) = Receiver_Address
         and Payload(Result) /= null;

   procedure Send_Clear_Request
      (Sender : Module_Mailbox;
      Receiver_Address : Message_Address;
      Request_ID : Request_ID_Type;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Receiver_Address.Module_ID = This_Module
      ;

   procedure Send_Clear_Request
      (Sender : Module_Mailbox;
      Receiver_Address : Message_Address;
      Request_ID : Request_ID_Type;
      Status : out Status_Type;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Receiver_Address.Module_ID = This_Module
         and then Receiver_Address.Domain_ID = Domain_ID
      ;

   procedure Send_Clear_Request
      (Sender : Module_Mailbox;
      Receiving_Module : Module_Metadata;
      Request_ID : Request_ID_Type;
      Receiving_Domain : Domain_Metadata := This_Domain;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Receiving_Module.Module_ID = This_Module
         and then Receives(Receiving_Module, Clear_Request_Msg)
         and then Has_Module(Receiving_Domain, Receiving_Module.Module_ID)
      ;

   procedure Send_Clear_Request
      (Sender : Module_Mailbox;
      Receiving_Module : Module_Metadata;
      Request_ID : Request_ID_Type;
      Status : out Status_Type;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Receiving_Module.Module_ID = This_Module
         and then Receives(Receiving_Module, Clear_Request_Msg)
         and then Has_Module(This_Domain, Receiving_Module.Module_ID)
      ;

   function Is_Clear_Request(Message : Message_Record) return Boolean is
      (CubedOS.Message_Types.Message_Type(Message) = Clear_Request_Msg);
   procedure Set_Request_Encode
      (Receiver_Address : in Message_Address;
      Sender_Address : in Message_Address;
      Request_ID : in Request_ID_Type;
      Priority : in System.Priority := System.Default_Priority;
      Result : out  Message_Record)
   with
      Pre => true
         and then Receiver_Address.Module_ID = This_Module,
      Post => CubedOS.Message_Types.Message_Type(Result) = Set_Request_Msg
         and CubedOS.Message_Types.Sender_Address(Result) = Sender_Address
         and CubedOS.Message_Types.Receiver_Address(Result) = Receiver_Address
         and Payload(Result) /= null;

   procedure Send_Set_Request
      (Sender : Module_Mailbox;
      Receiver_Address : Message_Address;
      Request_ID : Request_ID_Type;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Receiver_Address.Module_ID = This_Module
      ;

   procedure Send_Set_Request
      (Sender : Module_Mailbox;
      Receiver_Address : Message_Address;
      Request_ID : Request_ID_Type;
      Status : out Status_Type;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Receiver_Address.Module_ID = This_Module
         and then Receiver_Address.Domain_ID = Domain_ID
      ;

   procedure Send_Set_Request
      (Sender : Module_Mailbox;
      Receiving_Module : Module_Metadata;
      Request_ID : Request_ID_Type;
      Receiving_Domain : Domain_Metadata := This_Domain;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Receiving_Module.Module_ID = This_Module
         and then Receives(Receiving_Module, Set_Request_Msg)
         and then Has_Module(Receiving_Domain, Receiving_Module.Module_ID)
      ;

   procedure Send_Set_Request
      (Sender : Module_Mailbox;
      Receiving_Module : Module_Metadata;
      Request_ID : Request_ID_Type;
      Status : out Status_Type;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Receiving_Module.Module_ID = This_Module
         and then Receives(Receiving_Module, Set_Request_Msg)
         and then Has_Module(This_Domain, Receiving_Module.Module_ID)
      ;

   function Is_Set_Request(Message : Message_Record) return Boolean is
      (CubedOS.Message_Types.Message_Type(Message) = Set_Request_Msg);
   procedure Set_Reply_Encode
      (Receiver_Address : in Message_Address;
      Sender_Address : in Message_Address;
      Request_ID : in Request_ID_Type;
      Priority : in System.Priority := System.Default_Priority;
      Result : out  Message_Record)
   with
      Pre => true
         and then Sender_Address.Module_ID = This_Module,
      Post => CubedOS.Message_Types.Message_Type(Result) = Set_Reply_Msg
         and CubedOS.Message_Types.Sender_Address(Result) = Sender_Address
         and CubedOS.Message_Types.Receiver_Address(Result) = Receiver_Address
         and Payload(Result) /= null;

   procedure Send_Set_Reply
      (Sender : Module_Mailbox;
      Receiver_Address : Message_Address;
      Request_ID : Request_ID_Type;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Module_ID(Sender) = This_Module
      ;

   procedure Send_Set_Reply
      (Sender : Module_Mailbox;
      Receiver_Address : Message_Address;
      Request_ID : Request_ID_Type;
      Status : out Status_Type;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Module_ID(Sender) = This_Module
         and then Receiver_Address.Domain_ID = Domain_ID
      ;

   procedure Send_Set_Reply
      (Sender : Module_Mailbox;
      Receiving_Module : Module_Metadata;
      Request_ID : Request_ID_Type;
      Receiving_Domain : Domain_Metadata := This_Domain;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Module_ID(Sender) = This_Module
         and then Receives(Receiving_Module, Set_Reply_Msg)
         and then Has_Module(Receiving_Domain, Receiving_Module.Module_ID)
      ;

   procedure Send_Set_Reply
      (Sender : Module_Mailbox;
      Receiving_Module : Module_Metadata;
      Request_ID : Request_ID_Type;
      Status : out Status_Type;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Module_ID(Sender) = This_Module
         and then Receives(Receiving_Module, Set_Reply_Msg)
         and then Has_Module(This_Domain, Receiving_Module.Module_ID)
      ;

   function Is_Set_Reply(Message : Message_Record) return Boolean is
      (CubedOS.Message_Types.Message_Type(Message) = Set_Reply_Msg);
   procedure Add_Request_Encode
      (Receiver_Address : in Message_Address;
      Sender_Address : in Message_Address;
      Request_ID : in Request_ID_Type;
      Priority : in System.Priority := System.Default_Priority;
      Result : out  Message_Record)
   with
      Pre => true
         and then Receiver_Address.Module_ID = This_Module,
      Post => CubedOS.Message_Types.Message_Type(Result) = Add_Request_Msg
         and CubedOS.Message_Types.Sender_Address(Result) = Sender_Address
         and CubedOS.Message_Types.Receiver_Address(Result) = Receiver_Address
         and Payload(Result) /= null;

   procedure Send_Add_Request
      (Sender : Module_Mailbox;
      Receiver_Address : Message_Address;
      Request_ID : Request_ID_Type;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Receiver_Address.Module_ID = This_Module
      ;

   procedure Send_Add_Request
      (Sender : Module_Mailbox;
      Receiver_Address : Message_Address;
      Request_ID : Request_ID_Type;
      Status : out Status_Type;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Receiver_Address.Module_ID = This_Module
         and then Receiver_Address.Domain_ID = Domain_ID
      ;

   procedure Send_Add_Request
      (Sender : Module_Mailbox;
      Receiving_Module : Module_Metadata;
      Request_ID : Request_ID_Type;
      Receiving_Domain : Domain_Metadata := This_Domain;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Receiving_Module.Module_ID = This_Module
         and then Receives(Receiving_Module, Add_Request_Msg)
         and then Has_Module(Receiving_Domain, Receiving_Module.Module_ID)
      ;

   procedure Send_Add_Request
      (Sender : Module_Mailbox;
      Receiving_Module : Module_Metadata;
      Request_ID : Request_ID_Type;
      Status : out Status_Type;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Receiving_Module.Module_ID = This_Module
         and then Receives(Receiving_Module, Add_Request_Msg)
         and then Has_Module(This_Domain, Receiving_Module.Module_ID)
      ;

   function Is_Add_Request(Message : Message_Record) return Boolean is
      (CubedOS.Message_Types.Message_Type(Message) = Add_Request_Msg);
   procedure Add_Reply_Encode
      (Receiver_Address : in Message_Address;
      Sender_Address : in Message_Address;
      Request_ID : in Request_ID_Type;
      Priority : in System.Priority := System.Default_Priority;
      Result : out  Message_Record)
   with
      Pre => true
         and then Sender_Address.Module_ID = This_Module,
      Post => CubedOS.Message_Types.Message_Type(Result) = Add_Reply_Msg
         and CubedOS.Message_Types.Sender_Address(Result) = Sender_Address
         and CubedOS.Message_Types.Receiver_Address(Result) = Receiver_Address
         and Payload(Result) /= null;

   procedure Send_Add_Reply
      (Sender : Module_Mailbox;
      Receiver_Address : Message_Address;
      Request_ID : Request_ID_Type;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Module_ID(Sender) = This_Module
      ;

   procedure Send_Add_Reply
      (Sender : Module_Mailbox;
      Receiver_Address : Message_Address;
      Request_ID : Request_ID_Type;
      Status : out Status_Type;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Module_ID(Sender) = This_Module
         and then Receiver_Address.Domain_ID = Domain_ID
      ;

   procedure Send_Add_Reply
      (Sender : Module_Mailbox;
      Receiving_Module : Module_Metadata;
      Request_ID : Request_ID_Type;
      Receiving_Domain : Domain_Metadata := This_Domain;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Module_ID(Sender) = This_Module
         and then Receives(Receiving_Module, Add_Reply_Msg)
         and then Has_Module(Receiving_Domain, Receiving_Module.Module_ID)
      ;

   procedure Send_Add_Reply
      (Sender : Module_Mailbox;
      Receiving_Module : Module_Metadata;
      Request_ID : Request_ID_Type;
      Status : out Status_Type;
      Priority : System.Priority := System.Default_Priority)
   with
      Global => (In_Out => Mailboxes),
      Pre => Messaging_Ready
         and then Module_ID(Sender) = This_Module
         and then Receives(Receiving_Module, Add_Reply_Msg)
         and then Has_Module(This_Domain, Receiving_Module.Module_ID)
      ;

   function Is_Add_Reply(Message : Message_Record) return Boolean is
      (CubedOS.Message_Types.Message_Type(Message) = Add_Reply_Msg);

end CubedOS.Interpreter.API;
