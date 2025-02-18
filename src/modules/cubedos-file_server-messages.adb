--------------------------------------------------------------------------------
-- FILE   : cubedos-file_server-messages.adb
-- SUBJECT: Body of a package that implements the main part of the file server.
-- AUTHOR : (C) Copyright 2017 by Vermont Technical College
--
--------------------------------------------------------------------------------
pragma SPARK_Mode(Off);

-- For debugging...
with Ada.Exceptions;
with Ada.Text_IO;

with Ada.Sequential_IO;
with CubedOS.Lib;
with CubedOS.Message_Types;

use Ada.Text_IO;

package body CubedOS.File_Server.Messages is
   use type API.File_Handle_Type;
   use type API.Mode_Type;
   use CubedOS.Message_Types;

   Mailbox : aliased constant Module_Mailbox := Make_Module_Mailbox(This_Module, Mail_Target);

   procedure Init is
   begin
      Register_Module(Mailbox, 8);
   end Init;

   package Octet_IO is new Ada.Sequential_IO(Element_Type => CubedOS.Lib.Octet);

   type File_Record is
      record
         -- This record may hold additional components in the future.
         Underlying : Octet_IO.File_Type;
      end record;

   Files : array(API.Valid_File_Handle_Type) of File_Record;


   procedure Process_Open_Request(Incoming_Message : in Message_Record)
     with Pre => API.Is_Open_Request(Incoming_Message)
   is

      -- A linear search should be fine. This produces the lowest available handle.
      function Find_Free_Handle return API.File_Handle_Type is
      begin
         for I in API.Valid_File_Handle_Type loop
            if not Octet_IO.Is_Open(Files(I).Underlying) then
               return I;
            end if;
         end loop;
         return API.Invalid_Handle;
      end Find_Free_Handle;

      Mode       : API.Mode_Type;
      Status     : Message_Status_Type;
      Name       : File_Name_Type_Ptr;
      Underlying_Mode : Octet_IO.File_Mode;
      Handle     : constant API.File_Handle_Type := Find_Free_Handle;
   begin
      API.Open_Request_Decode(Incoming_Message, Mode, Name, Status);

      -- Don't even bother if there are no available handles.
      if Handle = API.Invalid_Handle then
         API.Send_Open_Reply
           (Sender => Mailbox,
            Receiver_Address => Sender_Address(Incoming_Message),
            Request_ID => Request_ID(Incoming_Message),
            Handle     => API.Invalid_Handle);
      elsif Status = Malformed then
         API.Send_Open_Reply
           (Sender => Mailbox,
            Receiver_Address => Sender_Address(Incoming_Message),
            Request_ID => Request_ID(Incoming_Message),
            Handle     => API.Invalid_Handle);
      else
         case Mode is
            when API.Read =>
               Underlying_Mode := Octet_IO.In_File;
               Octet_IO.Open(Files(Handle).Underlying, Underlying_Mode, String(Name.all));

            when API.Write =>
               Underlying_Mode := Octet_IO.Out_File;
               Octet_IO.Create(Files(Handle).Underlying, Underlying_Mode, String(Name.all));
         end case;

         API.Send_Open_Reply
           (Sender => Mailbox,
            Receiver_Address => Sender_Address(Incoming_Message),
            Request_ID => Request_ID(Incoming_Message),
            Handle     => Handle);
      end if;

   exception
      when others =>
         -- Open failed. Send back an invalid handle.
         API.Send_Open_Reply
           (Sender => Mailbox,
            Receiver_Address => Sender_Address(Incoming_Message),
            Request_ID => Request_ID(Incoming_Message),
            Handle     => API.Invalid_Handle);
   end Process_Open_Request;


   procedure Process_Read_Request(Incoming_Message : in Message_Record)
     with Pre => API.Is_Read_Request(Incoming_Message)
   is
      Handle : API.File_Handle_Type;
      Amount : API.Read_Size_Type;
      Status : Message_Status_Type;
      Size   : API.Read_Result_Size_Type;
      Data   : CubedOS.Lib.Octet_Array(0 .. Positive(Read_Size_Type'Last) - 1);
   begin
      -- If the read request doesn't decode properly we just don't send a reply at all?
      API.Read_Request_Decode(Incoming_Message, Handle, Amount, Status);
      if Status = Success then
         if Octet_IO.Is_Open(Files(Handle).Underlying) then
            Size := 0;
            begin
               while Size < Read_Result_Size_Type(Amount) loop
                  Octet_IO.Read(Files(Handle).Underlying, Data(Integer(Size)));
                  Size := Size + 1;
               end loop;
            exception
               when Octet_IO.End_Error =>
                  null;
            end;
            -- Send what we have (could be zero octets!).
            API.Send_Read_Reply
              (Sender => Mailbox,
               Receiver_Address => Sender_Address(Incoming_Message),
               Request_ID => Request_ID(Incoming_Message),
               Handle     => Handle,
               File_Data       => Data);
         end if;
      end if;
   end Process_Read_Request;


   procedure Process_Write_Request(Incoming_Message : in Message_Record)
     with Pre => API.Is_Write_Request(Incoming_Message)
   is
      Handle : API.File_Handle_Type;
      Status : Message_Status_Type;
      Size   : API.Read_Result_Size_Type;
      Data   : API.Octet_Array_Ptr;
   begin
      -- If the read request doesn't decode properly we just don't send a reply at all?
      API.Write_Request_Decode(Incoming_Message, Handle, Data, Status);
      if Status = Success then
         if Octet_IO.Is_Open(Files(Handle).Underlying) then
            Size := 0;
            begin
               -- Loop thorugh data to write each character
               while Size < Read_Result_Size_Type(Data'Length) loop
                  Octet_IO.Write(Files(Handle).Underlying, Data(Natural(Size)));
                  Size := Size + 1;
               end loop;
            exception
               when Octet_IO.End_Error =>
                  null;
            end;
            API.Send_Write_Reply
              (Sender => Mailbox,
               Receiver_Address => Sender_Address(Incoming_Message),
               Request_ID => Request_ID(Incoming_Message),
               Handle     => Handle,
               Amount     => Write_Result_Size_Type(Size));
         end if;
      end if;
   end Process_Write_Request;


   procedure Process_Close_Request(Incoming_Message : in Message_Record)
     with Pre => API.Is_Close_Request(Incoming_Message)
   is
      Handle : API.Valid_File_Handle_Type;
      Status : Message_Status_Type;
   begin
      API.Close_Request_Decode(Incoming_Message, Handle, Status);
      if Status = Success then
         if Octet_IO.Is_Open(Files(Handle).Underlying) then
            Octet_IO.Close(Files(Handle).Underlying);
         end if;
      end if;
   end Process_Close_Request;


-- TODO --
   procedure Process(Incoming_Message : in Message_Record) is
   begin
      if API.Is_Open_Request(Incoming_Message) then
         Process_Open_Request(Incoming_Message);
      elsif API.Is_Read_Request(Incoming_Message) then
         Process_Read_Request(Incoming_Message);
      elsif API.Is_Write_Request(Incoming_Message) then
         Process_Write_Request(Incoming_Message);
      elsif API.Is_Close_Request(Incoming_Message) then
         Process_Close_Request(Incoming_Message);
      end if;

   exception
      when Ex : others =>
         Ada.Text_IO.Put_Line("Unhandled exception in File_Server message processor...");
         Ada.Text_IO.Put_Line(Ada.Exceptions.Exception_Information(Ex));
   end Process;



   task body Message_Loop is
      Incoming_Message : Message_Record;
   begin
      Message_Manager.Wait;

      loop
         Message_Manager.Read_Next(Mailbox, Incoming_Message);
         Process(Incoming_Message);
         Delete(Incoming_Message);
         pragma Loop_Invariant(Payload(Incoming_Message) = null);
      end loop;
   end Message_Loop;

end CubedOS.File_Server.Messages;
