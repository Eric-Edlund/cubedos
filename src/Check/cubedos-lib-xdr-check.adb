--------------------------------------------------------------------------------
-- FILE   : check_message_manager.ads
-- SUBJECT: Body of an XDR encoding/decoding package test.
-- AUTHOR : (C) Copyright 2017 by Vermont Technical College
--
--------------------------------------------------------------------------------
--with Ada.Exceptions;
with Ada.Assertions;
with Ada.Text_IO;
with CubedOS.Lib.XDR;
--with Ada.Characters.Handling;

--use Ada.Exceptions;
use Ada.Assertions;
use Ada.Text_IO;
use CubedOS.Lib;
use CubedOS.Lib.XDR;
--use Ada.Characters.Handling;

package body CubedOS.Lib.XDR.Check is

   -- Test encoding/decoding of XDR 32 bit integer.
   procedure Test_Encode_Decode_1 is
      Data_1 : XDR_Array;
      Data_2 : XDR_Array;
      Position : constant XDR_Index_Type := 0;
      Last : XDR_Index_Type;
      Value_1 : constant XDR_Integer := 16#12345678#; -- Test when all octets are filled.
      Value_2 : constant XDR_Integer := 16#1234#;     -- Test with a smaller value.
      Value_Decoded : XDR_Integer;
      Octet_Value_1 : constant XDR_Octet := 16#12#;
      Octet_Value_2 : constant XDR_Octet := 16#34#;
      Octet_Value_3 : constant XDR_Octet := 16#56#;
      Octet_Value_4 : constant XDR_Octet := 16#78#;

   begin
      Data_1 := (others => 0);
      Encode(Value_1, Data_1, Position, Last);
      Encode(Value_2, Data_2, Position, Last);
      Assert(Data_1(Position + 0) = Octet_Value_1, "MSB Encoded incorrectly");
      Assert(Data_1(Position + 1) = Octet_Value_2, "Encoded incorrectly");
      Assert(Data_1(Position + 2) = Octet_Value_3, "Encoded incorrectly");
      Assert(Data_1(Position + 3) = Octet_Value_4, "LSB Encoded incorrectly");

      Assert(Data_2(Position + 2) = Octet_Value_1, "MSB Encoded incorrectly");
      Assert(Data_2(Position + 3) = Octet_Value_2, "Encoded incorrectly");

      -- Decode one of the encoded values;
      Decode(Data_1, Position, Value_Decoded, Last);
      Assert(Value_Decoded = Value_1, "Decoded incorrectly, expected:" &
               XDR_Integer'Image(Value_1) & " Received:" & XDR_Integer'Image(Value_Decoded));
   end Test_Encode_Decode_1;


   -- Test encoding/decoding of XDR 32 bit unsigned integer.
   procedure Test_Encode_Decode_2 is
      Data : XDR_Array;
      Position : constant XDR_Index_Type := 0;
      Last : XDR_Index_Type;
      Value : constant XDR_Integer := 16#12345678#;
      Value_Decoded : XDR_Integer;
      Octet_Value_1 : constant XDR_Octet := 16#12#;
      Octet_Value_2 : constant XDR_Octet := 16#34#;
      Octet_Value_3 : constant XDR_Octet := 16#56#;
      Octet_Value_4 : constant XDR_Octet := 16#78#;
   begin
      Data := (others => 0);
      Encode(Value, Data, Position, Last);
      Assert(Data(Position + 0) = Octet_Value_1, "MSB Encoded incorrectly");
      Assert(Data(Position + 1) = Octet_Value_2, "Encoded incorrectly");
      Assert(Data(Position + 2) = Octet_Value_3, "Encoded incorrectly");
      Assert(Data(Position + 3) = Octet_Value_4, "LSB Encoded incorrectly");

      Decode(Data, Position, Value_Decoded, Last);
      Assert(Value_Decoded = Value, "Decoded incorrectly, expected:" &
               XDR_Integer'Image(Value) & " Received:" & XDR_Integer'Image(Value_Decoded));
   end Test_Encode_Decode_2;


   -- Test encoding/decoding of XDR boolean value
   procedure Test_Encode_Decode_3 is
      Data : XDR_Array;
      Position_1 : constant XDR_Index_Type := 0;
      Position_2 : constant XDR_Index_Type := 4;
      Last : Octet_Array_Index;
      Value_1 : constant XDR_Boolean := XDR_False;
      Value_2 : constant XDR_Boolean := XDR_True;
      Decoded_Value_1 : XDR_Boolean;
      Decoded_Value_2 : XDR_Boolean;
      Octet_Value_1 : constant XDR_Octet := 0;
      Octet_Value_2 : constant XDR_Octet := 1;
   begin
      Data := (others => 0);
      Encode(Value_1, Data, Position_1, Last);
      Encode(Value_2, Data, Position_2, Last);
      Assert(Data(Position_1 + 3) = Octet_Value_1, "'False' Encoded incorrectly");
      Assert(Data(Position_2 + 3) = Octet_Value_2, "'True' Encoded incorrectly");

      Decode(Data, Position_1, Decoded_Value_1, Last);
      Decode(Data, Position_2, Decoded_Value_2, Last);
      Assert(Decoded_Value_1 = Value_1, "'False' Decoded incorrectly");
      Assert(Decoded_Value_2 = Value_2, "'True' Decoded incorrectly");
   end Test_Encode_Decode_3;


   -- Test encoding/decoding of XDR 64 bit integer.
   procedure Test_Encode_Decode_4 is
      Data : XDR_Array;
      Position : constant XDR_Index_Type := 0;
      Value : constant XDR_Hyper := 16#1234567876543210#;
      Decoded_Value : XDR_Hyper;
      Last : XDR_Index_Type;
      Octet_Value_1 : constant XDR_Octet := 16#12#;
      Octet_Value_2 : constant XDR_Octet := 16#34#;
      Octet_Value_3 : constant XDR_Octet := 16#56#;
      Octet_Value_4 : constant XDR_Octet := 16#78#;
      Octet_Value_5 : constant XDR_Octet := 16#76#;
      Octet_Value_6 : constant XDR_Octet := 16#54#;
      Octet_Value_7 : constant XDR_Octet := 16#32#;
      Octet_Value_8 : constant XDR_Octet := 16#10#;
   begin
      Data := (others => 0);
      Encode(Value, Data, Position, Last);
      Assert(Data(Position) = Octet_Value_1, "MSB Encoded incorrectly");
      Assert(Data(Position + 1) = Octet_Value_2, "Encoded incorrectly");
      Assert(Data(Position + 2) = Octet_Value_3, "Encoded incorrectly");
      Assert(Data(Position + 3) = Octet_Value_4, "Encoded incorrectly");
      Assert(Data(Position + 4) = Octet_Value_5, "Encoded incorrectly");
      Assert(Data(Position + 5) = Octet_Value_6, "Encoded incorrectly");
      Assert(Data(Position + 6) = Octet_Value_7, "Encoded incorrectly");
      Assert(Data(Position + 7) = Octet_Value_8, "LSB Encoded incorrectly");

      Decode(Data, Position, Decoded_Value, Last);
      Assert(Decoded_Value = Value, "Decoded incorrectly");
   end Test_Encode_Decode_4;


   -- Test encoding/decoding of XDR unsigned 64 bit integer.
   procedure Test_Encode_Decode_5 is
      Data : XDR_Array;
      Position : constant XDR_Index_Type := 0;
      Value : constant XDR_Hyper := 16#1234567876543210#;
      Decoded_Value : XDR_Hyper;
      Last : XDR_Index_Type;
      Octet_Value_1 : constant XDR_Octet := 16#12#;
      Octet_Value_2 : constant XDR_Octet := 16#34#;
      Octet_Value_3 : constant XDR_Octet := 16#56#;
      Octet_Value_4 : constant XDR_Octet := 16#78#;
      Octet_Value_5 : constant XDR_Octet := 16#76#;
      Octet_Value_6 : constant XDR_Octet := 16#54#;
      Octet_Value_7 : constant XDR_Octet := 16#32#;
      Octet_Value_8 : constant XDR_Octet := 16#10#;
   begin
      Data := (others => 0);
      Encode(Value, Data, Position, Last);
      Assert(Data(Position) = Octet_Value_1, "MSB Encoded incorrectly");
      Assert(Data(Position + 1) = Octet_Value_2, "Encoded incorrectly");
      Assert(Data(Position + 2) = Octet_Value_3, "Encoded incorrectly");
      Assert(Data(Position + 3) = Octet_Value_4, "Encoded incorrectly");
      Assert(Data(Position + 4) = Octet_Value_5, "Encoded incorrectly");
      Assert(Data(Position + 5) = Octet_Value_6, "Encoded incorrectly");
      Assert(Data(Position + 6) = Octet_Value_7, "Encoded incorrectly");
      Assert(Data(Position + 7) = Octet_Value_8, "LSB Encoded incorrectly");

      Decode(Data, Position, Decoded_Value, Last);
      Assert(Decoded_Value = Value, "Decoded incorrectly");
   end Test_Encode_Decode_5;


   -- Test encoding/decoding of XDR single precision float.
   procedure Test_Encode_Decode_6 is
      Data : XDR_Array;
      Decoded_Value : XDR_Float;
      Last : XDR_Index_Type;
   begin
      Data := (others => 0);
      Encode(XDR_Float'(0.0), Data, 0, Last);
      Decode(Data, 0, Decoded_Value, Last);
      Assert(Decoded_Value = 0.0, "Decoded incorrectly");

      Data := (others => 0);
      Encode(XDR_Float'Last, Data, 0, Last);
      Decode(Data, 0, Decoded_Value, Last);
      Assert(Decoded_Value = XDR_Float'Last, "Decoded incorrectly");

      Data := (others => 0);
      Encode(XDR_Float'First, Data, 0, Last);
      Decode(Data, 0, Decoded_Value, Last);
      Assert(Decoded_Value = XDR_Float'First, "Decoded incorrectly");

      Data := (others => 0);
      Encode(XDR_Float'(3.141592653589793E+10), Data, 0, Last);
      Decode(Data, 0, Decoded_Value, Last);
      Assert(Decoded_Value = 3.141592653589793E+10, "Decoded incorrectly");
   end Test_Encode_Decode_6;


   -- Test encoding/decoding of XDR double precision float.
   procedure Test_Encode_Decode_7 is
      Data : XDR_Array;
      Decoded_Value : XDR_Double;
      Last : XDR_Index_Type;
   begin
      Data := (others => 0);
      Encode(XDR_Double'(0.0), Data, 0, Last);
      Decode(Data, 0, Decoded_Value, Last);
      Assert(Decoded_Value = 0.0, "Decoded incorrectly");

      Data := (others => 0);
      Encode(XDR_Double'Last, Data, 0, Last);
      Decode(Data, 0, Decoded_Value, Last);
      Assert(Decoded_Value = XDR_Double'Last, "Decoded incorrectly");

      Data := (others => 0);
      Encode(XDR_Double'First, Data, 0, Last);
      Decode(Data, 0, Decoded_Value, Last);
      Assert(Decoded_Value = XDR_Double'First, "Decoded incorrectly");

      Data := (others => 0);
      Encode(XDR_Double'(3.141592653589793E+100), Data, 0, Last);
      Decode(Data, 0, Decoded_Value, Last);
      Assert(Decoded_Value = 3.141592653589793E+100, "Decoded incorrectly");
   end Test_Encode_Decode_7;


   -- Test encoding/decoding of fixed length opaque data.
   procedure Test_Encode_Decode_8 is
      Data : XDR_Array;
      Value_1 : constant Octet_Array(0 .. 5) := (others => 2);
      Value_2 : constant Octet_Array(0 .. 7) := (others => 2);
      Decoded_Value_1 : Octet_Array(0 .. 5);
      Decoded_Value_2 : Octet_Array(0 .. 7);
      Last : XDR_Index_Type;
   begin
      Data := (others => 1);

      -- Try encoding...
      Encode(Value_1, Data, 0, Last);
      --Assert(Data(0 .. 5) = Value_1, "Array encoded incorrectly");
      Assert
        (Data(Value_1'Length) = 0 and Data(Value_1'Length + 1) = 0,
         "Padding encoded incorrectly");

      -- Try decoding...
      Decode(Data, 0, Decoded_Value_1, Last);
      Assert(Decoded_Value_1 = Value_1, "Decoded incorrectly");

      Data := (others => 1);

      -- Try encoding...
      Encode(Value_2, Data, 0, Last);
      --Assert(Data(0 .. 7) = Value_2, "Array encoded incorrectly");

      -- Try decoding...
      Decode(Data, 0, Decoded_Value_2, Last);
      Assert(Decoded_Value_2 = Value_2, "Decoded incorrectly");
   end Test_Encode_Decode_8;

    -- Test encoding/decoding of fixed length string.
   procedure Test_Encode_Decode_9 is
      Data : XDR_Array;
      Value : constant String := "Hello";
      Last : XDR_Index_Type;
      Decoded_Value : String(1 .. 5);
      Position : constant XDR_Index_Type := 0;
   begin
      Data := (others => 0);
      Encode(Value, Data, Position, Last);
      Assert(Data(Position + 0) = Character'Pos('H'), "Encoded incorrectly, received: "
             & XDR_Octet'Image(Data(Position + 4)) & " Expected :" & Integer'Image(Character'Pos('H')));
      Assert(Data(Position + 1) = Character'Pos('e'), "Encoded incorrectly");
      Assert(Data(Position + 2) = Character'Pos('l'), "Encoded incorrectly");
      Assert(Data(Position + 3) = Character'Pos('l'), "Encoded incorrectly");
      Assert(Data(Position + 4) = Character'Pos('o'), "Encoded incorrectly");

      Decode(Data, Position, Decoded_Value, Last);
      Assert(Decoded_Value = Value, "Decoded incorrectly, expected: " & Value & " Received: " & Decoded_Value);
   end Test_Encode_Decode_9;

   -- Test encoding/decoding of XDR 32 bit signed integer.
   procedure Test_Encode_Decode_10 is
      Data_1 : XDR_Array;
      Data_2 : XDR_Array;
      Data_3 : XDR_Array;
      Position : constant XDR_Index_Type := 0;
      Last : XDR_Index_Type;
      Value_1 : constant XDR_Integer := -12345678;
      Value_2 : constant XDR_Integer := -1234;
      Value_3 : constant XDR_Integer := -2 ** 31;
      Decoded_Value_1, Decoded_Value_2, Decoded_Value_3: XDR_Integer;

   begin
      Data_1 := (others => 0);
      Data_2 := (others => 0);
      Data_3 := (others => 0);

      Encode(Value_1, Data_1, Position, Last);
      Encode(Value_2, Data_2, Position, Last);
      Encode(Value_3, Data_3, Position, Last);

      Decode(Data_1, Position, Decoded_Value_1, Last);
      Assert(Decoded_Value_1 = Value_1, "Decoded incorrectly, expected:" &
               XDR_Integer'Image(Value_1) & " Received:" & XDR_Integer'Image(Decoded_Value_1));

      Decode(Data_2, Position, Decoded_Value_2, Last);
      Assert(Decoded_Value_2 = Value_2, "Decoded incorrectly, expected:" &
               XDR_Integer'Image(Value_2) & " Recieved:" & XDR_Integer'Image(Decoded_Value_2));

      Decode(Data_3, Position, Decoded_Value_3, Last);
      Assert(Decoded_Value_3 = Value_3, "Decoded incorrectly, expected;" &
               XDR_Integer'Image(Value_3) & " Recieved:" & XDR_Integer'Image(Decoded_Value_3));
   end Test_Encode_Decode_10;

   -- Test encoding/decoding of XDR 64 bit signed integer.
   procedure Test_Encode_Decode_11 is
      Data_1, Data_2, Data_3 : XDR_Array;
      Position : constant XDR_Index_Type := 0;
      Value_1 : constant XDR_Hyper := (-2**63);
      Value_2 : constant XDR_Hyper := -123456789123456;
      Value_3 : constant XDR_Hyper := (-2**1);
      Decoded_Value_1, Decoded_Value_2, Decoded_Value_3 : XDR_Hyper;
      Last : XDR_Index_Type;
   begin

      Data_1 := (others => 0);
      Data_2 := (others => 0);
      Data_3 := (others => 0);

      Encode(Value_1, Data_1, Position, Last);
      Encode(Value_2, Data_2, Position, Last);
      Encode(Value_3, Data_3, Position, Last);

      Decode(Data_1, Position, Decoded_Value_1, Last);
      Assert(Decoded_Value_1 = Value_1, "Decoded incorrectly, expected: " &
               XDR_Hyper'Image(Value_1) & " Recieved: " & XDR_Hyper'Image(Decoded_Value_1));

      Decode(Data_2, Position, Decoded_Value_2, Last);
      Assert(Decoded_Value_2 = Value_2, "Decoded incorrectly, expected: " &
               XDR_Hyper'Image(Value_2) & " Recieved: " & XDR_Hyper'Image(Decoded_Value_2));


      Decode(Data_3, Position, Decoded_Value_3, Last);
      Assert(Decoded_Value_3 = Value_3, "Decoded incorrectly, expected: " &
               XDR_Hyper'Image(Value_3) & " Recieved: " & XDR_Hyper'Image(Decoded_Value_3));
   end Test_Encode_Decode_11;

   procedure Run_Tests is
   begin
      Put("XDR: Encode/Decode Integer"); Test_Encode_Decode_1; Put_Line(" (Ok)");
      Put("XDR: Encode/Decode Unsigned"); Test_Encode_Decode_2; Put_Line(" (Ok)");
      Put("XDR: Encode/Decode Boolean"); Test_Encode_Decode_3; Put_Line(" (Ok)");
      Put("XDR: Encode/Decode Hyper"); Test_Encode_Decode_4; Put_Line(" (Ok)");
      Put("XDR: Encode/Decode Unsigned Hyper"); Test_Encode_Decode_5; Put_Line(" (Ok)");
      Put("XDR: Encode/Decode Float"); Test_Encode_Decode_6; Put_Line(" (Ok)");
      Put("XDR: Encode/Decode Double"); Test_Encode_Decode_7; Put_Line(" (Ok)");
      Put("XDR: Encode/Decode Fixed Opaque Data"); Test_Encode_Decode_8; Put_Line(" (Ok)");
      Put("XDR: Encode/Decode String"); Test_Encode_Decode_9; Put_Line(" (Ok)");
      Put("XDR: Encode/Decode Signed Integer"); Test_Encode_Decode_10; Put_Line(" (Ok)");
      Put("XDR: Encode/Decode Signed Hyper"); Test_Encode_Decode_11; Put_Line(" (Ok)");
   end Run_Tests;


end CubedOS.Lib.XDR.Check;
