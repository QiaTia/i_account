import 'package:my_app/api/store/store.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/transfer_task.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos_transfer_manger.dart';
import 'package:tencentcloud_cos_sdk_plugin/enums.dart';
import 'package:tencentcloud_cos_sdk_plugin/fetch_credentials.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';

class FetchCredentials implements IFetchCredentials{
  @override
  Future<SessionQCloudCredentials> fetchSessionCredentials() async {
    // 首先从您的临时密钥服务器获取包含了密钥信息的响应，例如：
    try {
      var response = await getCosSecret();
      // 然后解析响应，获取临时密钥信息
      var data = response.data?['data'];
      // 最后返回临时密钥信息对象
      return SessionQCloudCredentials(
          secretId: data['credentials']['tmpSecretId'],// 临时密钥 SecretId
          secretKey: data['credentials']['tmpSecretKey'],// 临时密钥 SecretKey
          token: data['credentials']['sessionToken'],// 临时密钥 Token
          startTime: data['startTime'],//临时密钥有效起始时间，单位是秒
          expiredTime: data['expiredTime']//临时密钥有效截止时间戳，单位是秒
      );
    } catch (exception) {
      throw ArgumentError();
    }
  }
}

class CosClient {
  final Cos cos = Cos();
  /// 默认上储存桶
  final String bucket;
  /// 统一前缀, 用户文件类型分组
  final String prefix;
  /// 对象存储实列
  CosClient({ this.prefix = "store-images", this.bucket = 'bwda-1305015670' });
  /// 初始化
  init() async {
    await cos.initWithSessionCredential(FetchCredentials());
    // 存储桶所在地域简称，例如广州地区是 ap-guangzhou
    String region = "ap-nanjing";
    // 创建 CosXmlServiceConfig 对象，根据需要修改默认的配置参数
    CosXmlServiceConfig serviceConfig = CosXmlServiceConfig(
      region: region,
      isDebuggable: true,
      isHttps: true,
    );
    // 注册默认 COS Service
    await cos.registerDefaultService(serviceConfig);
    // 创建 TransferConfig 对象，根据需要修改默认的配置参数
    // TransferConfig 可以设置智能分块阈值 默认对大于或等于2M的文件自动进行分块上传，可以通过如下代码修改分块阈值
    TransferConfig transferConfig = TransferConfig(
        forceSimpleUpload: false,
        enableVerification: true,
        divisionForUpload: 2097152, // 设置大于等于 2M 的文件进行分块上传
        sliceSizeForUpload: 1048576, //设置默认分块大小为 1M
    );
    // 注册默认 COS TransferManger
    await cos.registerDefaultTransferManger(serviceConfig, transferConfig);
    // 也可以通过 registerService 和 registerTransferManger 注册其他实例， 用于后续调用
    // 一般用 region 作为注册的 key
    // String newRegion = "NEW_COS_REGION";
    // await Cos().registerService(newRegion, serviceConfig..region = newRegion);
    // await Cos().registerTransferManger(newRegion, serviceConfig..region = newRegion, transferConfig);
  }
  /// 上传文件对象
  Future<TransferTask> putObject(String srcPath, CosResultListener listener) async {
    /// 获取 TransferManager
    CosTransferManger transferManager = cos.getDefaultTransferManger();

    String cosPath = getObjectKey('jpg'); //对象在存储桶中的位置标识符，即称对象键
    
    /// 若存在初始化分块上传的 UploadId，则赋值对应的 uploadId 值用于续传；否则，赋值 null
    String? _uploadId;
  
    //初始化分块完成回调
    initMultipleUploadCallback(String bucket, String cosKey, String uploadId) {
      //用于下次续传上传的 uploadId
      _uploadId = uploadId;
    }
    /// 注册结果监听
    ResultListener resultListener = ResultListener(
      (header, result) {
        print(result);
        if (listener.successCallBack != null) listener.successCallBack!(header, result);
      }, 
      (clientException, serviceException) {
        if (listener.failCallBack != null) listener.failCallBack!(clientException, serviceException);
    });

    //开始上传
    TransferTask transferTask = await transferManager.upload(bucket, cosPath,
      filePath: srcPath,
      uploadId: _uploadId,
      resultListener: resultListener,  
      stateCallback: listener.stateCallback,
      progressCallBack: listener.progressCallBack,
      initMultipleUploadCallback: initMultipleUploadCallback
    );
    return transferTask;
    /// 暂停任务
    //transferTask.pause();
    /// 恢复任务
    //transferTask.resume();
    /// 取消任务
    //transferTask.cancel();
  }
  getObjectKey(String suffix) {
    var now = DateTime.now();
    String year = now.year.toString();
    String month = now.month.toString().padLeft(2, '0'); // 确保月份是两位数
    String day = now.day.toString().padLeft(2, '0'); // 确保日期是两位数
    var key = "${decimalToBase32(now.millisecondsSinceEpoch)}.$suffix";
    return "$prefix/$year/$month-$day/$key";
  }
  String decimalToBase32(int number) {
    const base32Chars = '0123456789ABCDEFGHIJKLMNOPQRSTUV';
    if (number == 0) return '0';
    String result = '';
    while (number > 0) {
      int remainder = number % 32;
      result = base32Chars[remainder] + result;
      number ~/= 32;
    }
    return result;
  }
}

class CosResultListener {
  /// 上传成功回调
  final ResultSuccessCallBack? successCallBack;
  /// 上传失败回调
  final ResultFailCallBack? failCallBack;
  /// 上传状态回调, 可以查看任务过程
  final StateCallBack? stateCallback;
  /// 上传进度回调
  final ProgressCallBack? progressCallBack;
  CosResultListener(this.successCallBack, this.failCallBack, this.stateCallback, this.progressCallBack);
}