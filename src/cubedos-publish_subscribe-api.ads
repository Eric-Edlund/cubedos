--------------------------------------------------------------------------------
-- FILE   : cubedos-publish_subscribe-api.ads
-- SUBJECT: Specification of a package that defines the publish/subscribe API
-- AUTHOR : (C) Copyright 2017 by Vermont Technical College
--
-- All the subprograms in this package must be task safe. They can be simultaneously called
-- from multiple tasks. If possible, make every subprogram here a pure function.
--
--------------------------------------------------------------------------------
pragma SPARK_Mode(On);

with CubedOS.Lib;
with Message_Manager;  use Message_Manager;
with System;

package CubedOS.Publish_Subscribe.API is

   type Status_Type is (Success, Failure);
   type Channel_ID_Type is range 1 .. 16;

   type Message_Type is
     (Subscribe_Request,   -- Ask to subscribe to a channel.
      Subscribe_Reply,     -- Success/failure of subscription request.
      Unsubscribe_Request, -- Ask to unsubscribe from a channel.
      Unsubscribe_Reply,   -- Success/failure of unsubscription request.
      Publish_Request,     -- Ask to publish to a channel.
      Publish_Reply,       -- Success/failure of a publish request.
      Publish_Result);     -- Delivery of data published to a channel.

   function Subscribe_Request_Encode
     (Sender_Domain : Domain_ID_Type;
      Sender     : Module_ID_Type;
      Request_ID : Request_ID_Type;
      Channel    : Channel_ID_Type;
      Priority   : System.Priority := System.Default_Priority) return Message_Record
     with Global => null;

   function Subscribe_Reply_Encode
     (Receiver_Domain : Domain_ID_Type;
      Receiver   : Module_ID_Type;
      Request_ID : Request_ID_Type;
      Channel    : Channel_ID_Type;
      Status     : Status_Type;
      Priority   : System.Priority := System.Default_Priority) return Message_Record
     with Global => null;

   function Unsubscribe_Request_Encode
     (Sender_Domain : Domain_ID_Type;
      Sender     : Module_ID_Type;
      Request_ID : Request_ID_Type;
      Channel    : Channel_ID_Type;
      Priority   : System.Priority := System.Default_Priority) return Message_Record
     with Global => null;

   function Unsubscribe_Reply_Encode
     (Receiver_Domain : Domain_ID_Type;
      Receiver   : Module_ID_Type;
      Request_ID : Request_ID_Type;
      Channel    : Channel_ID_Type;
      Status     : Status_Type;
      Priority   : System.Priority := System.Default_Priority) return Message_Record
     with Global => null;

   function Publish_Request_Encode
     (Sender_Domain : Domain_ID_Type;
      Sender     : Module_ID_Type;
      Request_ID : Request_ID_Type;
      Channel    : Channel_ID_Type;
      Message_Data : CubedOS.Lib.Octet_Array;
      Priority   : System.Priority := System.Default_Priority) return Message_Record
     with
       Global => null,
       Pre => Message_Data'Length <= XDR_Size_Type'Last - 8;

   function Publish_Reply_Encode
     (Receiver_Domain : Domain_ID_Type;
      Receiver   : Module_ID_Type;
      Request_ID : Request_ID_Type;
      Channel    : Channel_ID_Type;
      Status     : Status_Type;
      Priority   : System.Priority := System.Default_Priority) return Message_Record
     with Global => null;

   function Publish_Result_Encode
     (Receiver_Domain : Domain_ID_Type;
      Receiver   : Module_ID_Type;
      Request_ID : Request_ID_Type;
      Channel    : Channel_ID_Type;
      Message_Data : CubedOS.Lib.Octet_Array;
      Priority   : System.Priority := System.Default_Priority) return Message_Record
     with
       Global => null,
       Pre => Message_Data'Length <= XDR_Size_Type'Last - 8;


   function Is_Subscribe_Request(Message : Message_Record) return Boolean is
     (Message.Receiver = ID and Message.Message_ID = Message_Type'Pos(Subscribe_Request));

   function Is_Subscribe_Reply(Message : Message_Record) return Boolean is
     (Message.Sender = ID and Message.Message_ID = Message_Type'Pos(Subscribe_Reply));

   function Is_Unsubscribe_Request(Message : Message_Record) return Boolean is
     (Message.Receiver = ID and Message.Message_ID = Message_Type'Pos(Unsubscribe_Request));

   function Is_Unsubscribe_Reply(Message : Message_Record) return Boolean is
     (Message.Sender = ID and Message.Message_ID = Message_Type'Pos(Unsubscribe_Reply));

   function Is_Publish_Request(Message : Message_Record) return Boolean is
     (Message.Receiver = ID and Message.Message_ID = Message_Type'Pos(Publish_Request));

   function Is_Publish_Reply(Message : Message_Record) return Boolean is
     (Message.Sender = ID and Message.Message_ID = Message_Type'Pos(Publish_Reply));

   function Is_Publish_Result(Message : Message_Record) return Boolean is
     (Message.Sender = ID and Message.Message_ID = Message_Type'Pos(Publish_Result));


   procedure Subscribe_Request_Decode
     (Message : in  Message_Record;
      Channel : out Channel_ID_Type;
      Decode_Status : out Message_Status_Type)
   with
     Global => null,
     Depends => ((Channel, Decode_Status) => Message),
     Pre => Is_Subscribe_Request(Message);

   procedure Subscribe_Reply_Decode
     (Message : in  Message_Record;
      Channel : out Channel_ID_Type;
      Status  : out Status_Type;
      Decode_Status : out Message_Status_Type)
   with
     Global => null,
     Depends => ((Channel, Status, Decode_Status) => Message),
     Pre => Is_Subscribe_Reply(Message);

   procedure Unsubscribe_Request_Decode
     (Message : in  Message_Record;
      Channel : out Channel_ID_Type;
      Decode_Status : out Message_Status_Type)
   with
     Global => null,
     Depends => ((Channel, Decode_Status) => Message),
     Pre => Is_Unsubscribe_Request(Message);

   procedure Unsubscribe_Reply_Decode
     (Message : in  Message_Record;
      Channel : out Channel_ID_Type;
      Status  : out Status_Type;
      Decode_Status : out Message_Status_Type)
   with
     Global => null,
     Depends => ((Channel, Status, Decode_Status) => Message),
     Pre => Is_Unsubscribe_Reply(Message);

   procedure Publish_Request_Decode
     (Message : in  Message_Record;
      Channel : out Channel_ID_Type;
      Message_Data : out CubedOS.Lib.Octet_Array;
      Size    : out CubedOS.Lib.Octet_Array_Count;
      Decode_Status : out Message_Status_Type)
   with
     Global => null,
     Depends => (Channel => Message, Size => (Message, Message_Data), (Message_Data, Decode_Status) => (Message, Message_Data)),
     Pre => Is_Publish_Request(Message),
     Post => Size <= Message_Data'Length;

   procedure Publish_Reply_Decode
     (Message : in  Message_Record;
      Channel : out Channel_ID_Type;
      Status  : out Status_Type;
      Decode_Status : out Message_Status_Type)
   with
     Global => null,
     Depends => ((Channel, Status, Decode_Status) => Message),
     Pre => Is_Publish_Reply(Message);

   procedure Publish_Result_Decode
     (Message : in  Message_Record;
      Channel : out Channel_ID_Type;
      Message_Data : out CubedOS.Lib.Octet_Array;
      Size    : out CubedOS.Lib.Octet_Array_Count;
      Decode_Status : out Message_Status_Type)
   with
     Global => null,
     Depends => (Channel => Message, Size => (Message, Message_Data), (Message_Data, Decode_Status) => (Message, Message_Data)),
     Pre => Is_Publish_Result(Message),
     Post => Size <= Message_Data'Length;

end CubedOS.Publish_Subscribe.API;
