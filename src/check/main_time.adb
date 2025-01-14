--------------------------------------------------------------------------------
-- FILE   : main_time.adb
-- SUBJECT: The main file to test the time server package.
-- AUTHOR : (C) Copyright 2021 by Vermont Technical College
--
-- In order to test the time server module, you must run the produced executable in a console
-- window, and ^C out of it when a suitable time has passed. Then observe the behavior to ensure
-- the desired effects are happening.
--------------------------------------------------------------------------------
with Ada.Integer_Text_IO;
with Ada.Real_Time;
with Ada.Text_IO;
with CubedOS.Time_Server;
with CubedOS.Time_Server.API;
with CubedOS.Time_Server.Messages;
with Test_Constants;
with Message_Manager;
with GNAT.Time_Stamp;

use Ada.Integer_Text_IO;
use Ada.Text_IO;
use CubedOS.Time_Server;
use CubedOS.Time_Server.API;
use Message_Manager;
with CubedOS.Message_Types; use CubedOS.Message_Types;
with Name_Resolver;

procedure Main_Time is
   use type Ada.Real_Time.Time;

   -- Take the module ID of the file server because it isn't included in this test
   My_Module_ID : constant Module_ID_Type := Name_Resolver.File_Server;
   Metadata : constant Module_Metadata := Define_Module(My_Module_ID, Test_Constants.Receives_Tick_Messages'Access);
   My_Mailbox : constant Module_Mailbox := Make_Module_Mailbox(My_Module_ID, Metadata);

   Incoming_Message  : Message_Record;
   Series_ID         : Series_ID_Type;
   Count             : Series_Count_Type;
   Status            : Message_Status_Type;
   Start_Time        : Ada.Real_Time.Time;
   Relative_Time     : Ada.Real_Time.Time_Span;
   Relative_Duration : Duration;
   Absolute_Time     : String := GNAT.Time_Stamp.Current_Time;

   package Duration_IO is new Fixed_IO(Duration);
   use Duration_IO;
begin
   CubedOS.Time_Server.Messages.Init;

   Start_Time := Ada.Real_Time.Clock;
   Message_Manager.Register_Module(My_Mailbox, 8);

   Message_Manager.Skip_Mailbox_Initialization;

   -- Do some setup...
   Message_Manager.Wait;
   Send_Relative_Request(My_Mailbox, CubedOS.Time_Server.API.Mail_Target, 1, Ada.Real_Time.Milliseconds(3000), Periodic, 1);
   Put_Line("TX : Relative_Request message sent for 3 second periodic ticks; Series_ID = 1");

   Send_Relative_Request(My_Mailbox, CubedOS.Time_Server.API.Mail_Target, 1, Ada.Real_Time.Milliseconds(10000), One_Shot, 2);
   Put_Line("TX : Relative_Request message sent for 10 second one shot; Series_ID = 2");

   loop
      Message_Manager.Read_Next(My_Mailbox, Incoming_Message);
       --  Put_Line("+++ Fetch returned!");
       --  Put("+++ Sender    : "); Put(Incoming_Message.all.Sender); New_Line;
       --  Put("+++ Receiver  : "); Put(Incoming_Message.all.Receiver); New_Line;
       --  Put("+++ Message_ID: "); Put(Integer(Incoming_Message.all.Message_ID)); New_Line(2);

      Relative_Time := Ada.Real_Time.Clock - Start_Time;
      Relative_Duration := Ada.Real_Time.To_Duration(Relative_Time);
      Absolute_Time := GNAT.Time_Stamp.Current_Time;
      if Is_Tick_Reply(Incoming_Message) then
         Tick_Reply_Decode(Incoming_Message, Series_ID, Count, Status);
         if Status = Success then
            Put("Time Duration: "); Put(Relative_Duration); Put("     Time Stamp:      "); Put(Absolute_Time);
            Put("      Series " & Series_ID_Type'Image(Series_ID) & " -- "); Put(Natural(Count)); New_Line;

            -- Cancel series #1 after 10 ticks.
            if Series_ID = 1 and then Count = 10 then

               Send_Cancel_Request(My_Mailbox, CubedOS.Time_Server.API.Mail_Target, 1, Series_ID => 1);
               Put_Line("TX : Cancel_Request message sent for Series_ID = 1");
            end if;

         end if;
      end if;
   end loop;

end Main_Time;
