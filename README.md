MongoDB Driver for Delphi/FreePascal
-------------------------

A mongodb driver for Delphi/FreePascal in intermediary stage with a friendly API based on java driver.
The delphi native types are mapped onto Delphi Variant and the more complex types (like ObjectId, Array, etc) 
has an specific implementation.

The driver is tested with Delphi 7, Delphi XE and FreePascal (Lazarus 0.9.30.2/FPC 2.4.4), and probably work fine with another delphi versions above 7.
If someone is willing to test with other versions of Delphi, give me feedback and I will update this documentation. 
For a complete test, compile the source code, run unit tests and make sure the demo works.

The TPC connection may be use Delphi Sockets or Synapse, for compatibility with FreePascal.

Usage:
------
There are two main units to use to access a mongodb server: mongo.pas e BSONTypes.pas

Code Example Insert:
var
  mongo: TMongo;
  db: TMongoDB;
  coll: TMongoCollection;
  bson: IBSONObject;
  item: IBSONArray;
begin
  mongo := TMongo.Create;
  try
    mongo.Connect(${server.host}, ${server.port});
    db := mongo.getDB('testdb');
    coll := db.GetCollection('testcoll');

    bson := TBSONObject.NewFrom('code', 123)
                       .Put('name', 'Fabricio')
                       .Put('LocalDate', Date);

    item := TBSONArray.NewFrom('awesome')
                      .Put(43.29)
                      .Put(2012);

    bson.Put('items', item);

    coll.Insert(bson);
  finally
    mongo.Free;
  end;
end;

Class Definition:
-----------------	
The mongo.pas provide the classes:
 - TMongo: Represent the connection to a mongo server, with methods like GetDB(const ADBname: String): TMongoDB
 - TMongoDB: Represent a mongo Database, with methods like RunCommand and GetCollection
 - TMongoCollection: Represent a collection inside a Database, and has methods like: Insert, Update, Remove, 
                     CreateIndex, Find, etc.
 - TMongoCursor: Is a cursor to a query results. A cursor allows prepare a query before open, and the main methods 
                 are: Skip, Limit, BatchSize, Count, Size, Sort, Hint, Explain, Snapshot, and for iteration over 
								 returned rows: hasNext and Next;

Then BSONTypes.ps provide the classes what represent documents or value types:
 - IBSONObject: Is the document
 - IBSONArray: An array of values, which may contain other documents 
 - IObjectId: An specific implementation to BSON objectId type.
 - Another types could be created				 
								   