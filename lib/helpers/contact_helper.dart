import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const String contactTable = "contactTable";
const String idColumn = "idColumn";
const String nameColumn = "nameColumn";
const String emailColumn = "emailColumn";
const String phoneColumn = "phoneColumn";
const String imgColumn = "imgColumn";

class ContactHelper {

  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database? _db;

  Future<Database?> get db async {
    if(_db != null){
      return _db;
    }else{
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final path = join(await getDatabasesPath(), "contacts.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
            "$phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async{
    Database? dbContact = await db;

    if(dbContact != null){
      contact.id = await dbContact.insert(contactTable, contact.toMap());
    }
    return contact;
  }

  Future<Contact?> getContact(int id) async {
    Database? dbContact = await db;
    if(dbContact != null){
      List<Map> maps = await dbContact.query(contactTable, columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn], where:  "$idColumn = ?", whereArgs:  [id]);
      if(maps.isNotEmpty){
        return Contact.fromMap(maps.first);
      }
    }
    return null;
  }

  Future<int?> deleteContact(int id) async{
    Database? dbContact = await db;
    if(dbContact != null){
      return dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
    }
    return null;
  }

  Future<int?> updateContact(Contact contact) async {
    Database? dbContact = await db;
    if(dbContact != null) {
      return await dbContact.update(contactTable,
          contact.toMap(),
          where: "$idColumn = ?",
          whereArgs: [contact.id]);
    }
    return null;
  }

  Future<List<Contact>?> getAllContacts() async {
    Database? dbContact = await db;
    if(dbContact != null) {
      List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
      return listMap.map((e) => Contact.fromMap(e)).toList();
    }
    return null;
  }

  Future<int?> getNumber() async {
    Database? dbContact = await db;
    if(dbContact != null) {
      return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
    }
    return null;
  }

  Future<void> close() async {
    Database? dbContact = await db;
    if(dbContact != null) {
      dbContact.close();
    }
  }

}

class Contact {

  int? id;
  String?name;
  String? email;
  String? phone;
  String? img;

  Contact();

  Contact.fromMap(Map map){
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if(id != null){
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact (id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }

}

