import 'package:sqflite/sqflite.dart';
import '../model/record.dart';

class DBManager {
  static int version = 1;
  final int pageSize = 12;
  //单例类创建
  DBManager._internal();
  //保存单例
  static final DBManager _dbManager = DBManager._internal();
  //工厂构造函数
  factory DBManager() {
    return _dbManager;
  }
  //数据库
  late final Database db;

  /// 获取分页数据
  int getPageLimitStart(int page) {
    return pageSize * page - pageSize;
  }

  /// 考虑到数据库要在程序启动时先启动，而数据库的初始化是异步的，这里也采用异步函数，后面通过await函数同步执行
  Future<bool> openDB(String path) async {
    // sqfliteFfiInit()
    //获取数据库存放地址
    var databasesPath = await getDatabasesPath();
    String dbPath = '$databasesPath/$path.db';
    //打开数据库，如果数据库中没有对应的表格则创建
    db = await openDatabase(dbPath, version: 1,
        onCreate: (Database db, int version) {
      /// 创建分类表
      String dreamTable = "CREATE TABLE If NOT EXISTS `category` ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "name TEXT NOT NULL DEFAULT '',"
          "type INTEGER NOT NULL DEFAULT 1," // 类别类型: 1支出 2收入
          "icon TEXT NOT NULL,"
          "sort_num INTEGER NOT NULL," // 排序
          "created_at DATETIME DEFAULT CURRENT_TIMESTAMP,"
          "updated_at DATETIME,"
          "is_deleted INTEGER DEFAULT 0);"; // 是否已删除
      db.execute(dreamTable).then((_) {
        db.rawInsert(
            "INSERT INTO category(id, name,type,icon,sort_num,updated_at) VALUES"
            "(1,'餐饮',1,'58674',0,'2025-03-07T01:14:13.732172'),"
            "(2,'购物',1,'58780',1,'2025-03-07T01:14:13.732670'),"
            "(3,'日用',1,'58255',2,'2025-03-07T01:14:13.732710'),"
            "(4,'交通',1,'57815',3,'2025-03-07T01:14:13.732737'),"
            "(5,'蔬菜',1,'58259',4,'2025-03-07T01:14:13.732759'),"
            "(6,'水果',1,'58261',5,'2025-03-07T01:14:13.732787'),"
            "(7,'零食',1,'57632',6,'2025-03-07T01:14:13.732812'),"
            "(8,'运动',1,'57820',7,'2025-03-07T01:14:13.733289'),"
            "(9,'娱乐',1,'58381',8,'2025-03-07T01:14:13.733317'),"
            "(10,'通讯',1,'58530',9,'2025-03-07T01:14:13.733342'),"
            "(11,'服饰',1,'57693',10,'2025-03-07T01:14:13.733369'),"
            "(12,'美容',1,'57938',11,'2025-03-07T01:14:13.733396'),"
            "(13,'其他',1,'57939',99,'2025-03-07T01:14:13.733396');");
      });

      /// 记录项表
      String recordTable = "CREATE TABLE If NOT EXISTS `records` ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "amount REAL NOT NULL,"
          "name TEXT NOT NULL DEFAULT ''," //日记ID
          "category_id INTEGER NOT NULL," // 对应分类id
          "category_type INTEGER NOT NULL," // '1支出 2收入'
          "bill_year INTEGER NOT NULL DEFAULT 0," // 账单年月,方便做数据统计
          "bill_month INTEGER NOT NULL DEFAULT 0,"
          "bill_date DATETIME,"
          "remark TEXT NOT NULL DEFAULT '',"
          "pay_platform_id INTEGER DEFAULT 4," // 支付平台关联ID
          "created_at DATETIME DEFAULT CURRENT_TIMESTAMP,"
          "updated_at DATETIME,"
          "is_deleted INTEGER DEFAULT 0," // 是否已删除
          "origin_info TEXT)"; // 其他原始信息, 如平台导入原始信息
      db.execute(recordTable);

      /// 支付平台表 1:支付宝 2:微信 3:银联 4:其他
      var payTable = "CREATE TABLE If NOT EXISTS `pay_platform` ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "pay_name TEXT,"
          "pay_icon TEXT,"
          "created_at DATETIME DEFAULT CURRENT_TIMESTAMP,"
          "updated_at DATETIME,"
          "is_deleted INTEGER DEFAULT 0)";
      db.execute(payTable).then((_) {
        db.rawInsert(
            "INSERT INTO `pay_platform`(`pay_name`, `pay_icon`) VALUES('支付宝', 'alipay'),('微信', 'wechat'),('银联', 'unionpay'),('其他', 'other')");
      });
      /// 预算表
      var budgetTable = "CREATE TABLE budget ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "amount REAL NOT NULL,"
        "budget_month INTEGER NOT NULL DEFAULT 0,"
        "budget_year INTEGER NOT NULL DEFAULT 0,"
        "created_time DATETIME DEFAULT CURRENT_TIMESTAMP,"
        "updated_time DATETIME,"
        "is_deleted INTEGER DEFAULT 0);";
      db.execute(budgetTable).then((_) {
          db.execute("CREATE TRIGGER update_budget_time"
            "AFTER UPDATE ON budget "
            "BEGIN"
              "UPDATE budget SET updated_time = CURRENT_TIMESTAMP WHERE id = OLD.id;");
        });
    }, onUpgrade: (Database db, int oldVersion, int version) async {
      /// 需要更新的内容
    });

    return true;
  }

  /// 插入记录项目
  Future<int> insertRecord(RecordItem data) async {
    var billYear = data.billDate.year;
    var billMonth = data.billDate.month;
    return db.transaction((txn) async {
      String dataStr = "INSERT INTO `records`("
          "amount,"
          "name,"
          "category_id,"
          "category_type,"
          "bill_year,"
          "bill_month,"
          "bill_date,"
          "remark,"
          "pay_platform_id,"
          "origin_info,"
          "updated_at"
          ") VALUES(?, ?, ?, ?, ?, ?, ?,?,?,?, ?)";
      return txn.rawInsert(dataStr, [
        data.amount,
        data.name,
        data.categoryId,
        data.categoryType.state,
        billYear,
        billMonth,
        data.billDate.toIso8601String(),
        data.remark,
        data.payPlatformId ?? 4,
        data.originInfo ?? '',
        DateTime.now().toIso8601String()
      ]);
    });
  }

  /// 更新记录项目
  Future<int> updateRecord(RecordItem data) async {
    var billYear = data.billDate.year;
    var billMonth = data.billDate.month;
    String sqlData =
        "UPDATE `records` SET amount=?, name=?, category_id=?,bill_year=?, bill_month=?, bill_date=?, remark=?, updated_at=? WHERE id=?";
    int count = await db.rawUpdate(sqlData, [
      data.amount,
      data.name,
      data.categoryId,
      billYear,
      billMonth,
      data.billDate.toIso8601String(),
      data.remark,
      DateTime.now().toIso8601String(),
      data.id
    ]);
    return count;
  }

  /// 查询记录列表
  Future<PageResult<RecordItem>> selectRecordList(
      [CategoryType categoryType = CategoryType.expense,
      int page = 1,
      int? billYear,
      int? billMonth,
      String order = 'bill_date',
      String orderType = 'DESC']) async {
    var limitStart = getPageLimitStart(page);
    String data =
        "SELECT r.*, c.icon FROM `records` r LEFT JOIN category c ON r.category_id = c.id WHERE category_type = ?";
    // [categoryType, billYear, billMonth, limitStart, pageSize]
    String countStr = "SELECT COUNT(*) FROM `records` WHERE category_type = ${categoryType.state}";
    List<Object> query = [categoryType.state];
    if (billYear != null) {
      data += " AND bill_year = ?";
      countStr += " AND bill_year = $billYear";
      query.add(billYear);
    }
    if (billMonth != null) {
      data += " AND bill_month = ?";
      countStr += " AND bill_month = $billMonth";
      query.add(billMonth);
    }
    data += " ORDER BY `$order` $orderType LIMIT ?, ?";
    query.add(limitStart);
    query.add(pageSize);
    int? count = Sqflite.firstIntValue(await db.rawQuery(countStr));
    if (count == null || count == 0) {
      return PageResult(currentPage: page, pageSize: pageSize, total: 0, data: []);
    }
    List<Map<String, dynamic>> list = await db.rawQuery(data, query);
    List<RecordItem> models = list.map((e) => RecordItem.fromJson(e)).toList();
    return PageResult(currentPage: page, pageSize: pageSize, total: count, data: models);
  }

  /// 查询记录
  Future<RecordDetail?> selectRecordById(int id) async {
    String data =
        "SELECT r.*, c.icon, p.pay_name, p.pay_icon FROM `records` r LEFT JOIN category c ON r.category_id = c.id LEFT JOIN pay_platform p ON r.pay_platform_id = p.id WHERE r.id = ?";
    List<Map<String, dynamic>> list = await db.rawQuery(data, [id]);
    if (list.isEmpty) {
      return null;
    }
    //将查询到的数据映射成模型
    List<RecordDetail> models =
        list.map((e) => RecordDetail.fromJson(e)).toList();
    return models.first;
  }

  /// 删除记录
  Future<int> deleteRecord(int id) async {
    String data = "DELETE FROM `records` WHERE id = ?";
    int count = await db.rawDelete(data, [id]);
    return count;
  }

  /// 查询月度收入或支出合计
  Future<String> selectRecordTotal(CategoryType type, DateTime selectDate) async {
    var result = await db
      .rawQuery('SELECT SUM(amount) as `total` FROM `records` WHERE category_type = ? AND bill_year = ? AND bill_month = ?', [type.state, selectDate.year, selectDate.month])
      .catchError((err) {
        print('err:$err');
        throw err;
      });
    if (result.isNotEmpty) {
      return ((result.first['total']?? 0.0) as double).toStringAsFixed(2);
    } else {
      return '0.00';
    }
  }
  /// TODO: 查询记录条数
  Future<int> selectRecordCount(String dreamId) async {
    String data = "SELECT COUNT(*) FROM `records`";
    int? count = Sqflite.firstIntValue(await db.rawQuery(data));

    return count ?? 0;
  }

  /// 获取列表
  Future<List<CategoryItemProvider>> queryCategoryList(
      [CategoryType type = CategoryType.expense]) async {
    String data =
        "SELECT * FROM `category` WHERE type = ? AND is_deleted = 0 ORDER BY `sort_num` ASC";
    List<Map<String, dynamic>> list = await db.rawQuery(data, [type.state]);
    if (list.isEmpty) {
      return [];
    }
    // return list;
    List<CategoryItemProvider> models =
        list.map((e) => CategoryItemProvider.fromJson(e)).toList();
    return models;
  }

  /// 更新分类
  Future<int> updateCategory(CategoryItemProvider data) async {
    String sqlData =
        "UPDATE `category` SET name=?, icon=?, sort_num=?, updated_at=? WHERE id=?";
    return await db.rawUpdate(sqlData, [
      data.name,
      data.icon,
      data.sortNum,
      DateTime.now().toIso8601String(),
      data.id
    ]);
  }

  /// 删除分类
  Future<int> deleteCategory(int id) async {
    String data = "UPDATE `category` SET is_deleted = 1 WHERE id =?";
    return await db.rawDelete(data, [id]);
  }

  /// 插入分类
  Future<int> insertCategory(CategoryItemProvider data) async {
    String sqlData = "INSERT INTO `category`("
        "name,"
        "icon,"
        "type,"
        "sort_num,"
        "updated_at"
        ") VALUES(?,?,?,?,?)";
    return await db.rawInsert(sqlData, [
      data.name,
      data.icon,
      data.type.state,
      data.sortNum,
      DateTime.now().toIso8601String()
    ]);
  }
}

/// 格式化数字
String formatNumber(double num) {
  // 保留两位小数
  String fixed = num.toStringAsFixed(2);
  // 添加千位分隔符
  return fixed.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
    (Match m) => '${m[1]},'
  );
}

/// 拼接分页参数
class PageResult<T> {
  final int currentPage;
  final int pageSize;
  final int total;
  final List<T> data;
  PageResult({
    required this.currentPage,
    required this.pageSize,
    required this.total,
    required this.data,
  });
}
