{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2020 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnSM9;
{* |<PRE>
================================================================================
* 软件名称：开发包基础库
* 单元名称：SM9 基于椭圆曲线双线性映射的标识密码算法单元
* 单元作者：刘啸
* 备    注：参考了 GmSSL/PBC/Federico2014 源码。
*           二次、四次、十二次扩域分别有 U V W 乘法操作，元素分别用 FP2、FP4、FP12 表示
*           G1 与 G2 群里各用 TCnEccPoint 和 TCnFP2Point 类作为元素坐标点，包括 X Y
*           仿射坐标系/雅可比坐标系里的三元点也有加、乘、求反、Frobenius 等操作
*           并基于以上实现了基于 SM9 的 BN 曲线参数的基本 R-ate 计算
*           以及进一步实现了常规的签名验签、密钥封装、加解密与密钥交换等典型功能
*           均基于国密标准《SM9 标识密码算法》实现并通过示例数据验证
*           注意 Miller 算法是定义在 F(q^k) 扩域上的椭圆曲线中的，因而一个元素是 k 维向量
*           Miller 算法计算的现实意义是什么？
* 开发平台：Win7 + Delphi 5.0
* 兼容测试：暂未进行
* 本 地 化：该单元无需本地化处理
* 修改记录：2022.01.02 V1.3
*               实现密钥交换的功能
*           2022.01.01 V1.2
*               实现加解密的功能
*           2021.12.30 V1.1
*               实现签名验签与密钥封装的功能，计算速度略慢
*           2020.04.04 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils,
  CnContainers, CnBigNumber, CnECC, CnNativeDecl, CnSM3;

const
  // 一个参数 T，不知道叫啥，但 SM9 所选择的 BN 曲线里，
  // 基域特征、阶和弗罗贝尼乌斯自同态映射的迹均是 T 的指定的多项式表达式
  CN_SM9_T = '600000000058F98A';

  // SM9 椭圆曲线方程的 A 系数值
  CN_SM9_ECC_A = 0;

  // SM9 椭圆曲线方程的 B 系数值
  CN_SM9_ECC_B = 5;

  // SM9 椭圆曲线的素数域，也叫基域特征，在这里等于 36t^4 + 36t^3 + 24t^2 + 6t + 1：
  CN_SM9_FINITE_FIELD = 'B640000002A3A6F1D603AB4FF58EC74521F2934B1A7AEEDBE56F9B27E351457D';

  // SM9 椭圆曲线的阶，也就是总点数，在这里等于 36t^4 + 36t^3 + 18t^2 + 6t + 1：
  // （貌似叫 N，要乘以 cf 才能叫 Order，但这里 cf = 1，所以 N 和 Order 等价）
  CN_SM9_ORDER = 'B640000002A3A6F1D603AB4FF58EC74449F2934B18EA8BEEE56EE19CD69ECF25';

  // SM9 椭圆曲线的余因子，乘以 N 就得到阶
  CN_SM9_CF = 1;

  // SM9 椭圆曲线的嵌入次数，也就是 Prime 的最小嵌入次数次方对 Order 求模为 1
  CN_SM9_K = 12;

  // 弗罗贝尼乌斯自同态映射的迹，也就是 Hasse 定理中的 阶=q+1-trace 中的 trace
  // 在 SM9 椭圆曲线中等于 6t^2 + 1
  CN_SM9_FROBENIUS_TRACE = 'D8000000019062ED0000B98B0CB27659';

  // G1 生成元的单坐标
  CN_SM9_G1_P1X = '93DE051D62BF718FF5ED0704487D01D6E1E4086909DC3280E8C4E4817C66DDDD';
  CN_SM9_G1_P1Y = '21FE8DDA4F21E607631065125C395BBC1C1C00CBFA6024350C464CD70A3EA616';

  // G2 生成元的双坐标
  CN_SM9_G2_P2X0 = '3722755292130B08D2AAB97FD34EC120EE265948D19C17ABF9B7213BAF82D65B';
  CN_SM9_G2_P2X1 = '85AEF3D078640C98597B6027B441A01FF1DD2C190F5E93C454806C11D8806141';
  CN_SM9_G2_P2Y0 = 'A7CF28D519BE3DA65F3170153D278FF247EFBA98A71A08116215BBA5C999A7C7';
  CN_SM9_G2_P2Y1 = '17509B092E845C1266BA0D262CBEE6ED0736A96FA347C8BD856DC76B84EBEB96';

  // R-ate 对的计算参数，其实就是 6T + 2
  CN_SM9_6T_PLUS_2 = '02400000000215D93E';

  CN_SM9_FAST_EXP_P3 = '5C5E452404034E2AF12FCAD3B31FE2B0D62CD8FB7B497A0ADC53E586930846F1' +
    'BA4CADE09029E4717C0CA02D9B0D8649A5782C82FDB6B0A10DA3D71BCDB13FE5E0D49DE3AA8A4748' +
    '83687EE0C6D9188C44BF9D0FA74DDFB7A9B2ADA593152855';

  CN_SM9_FAST_EXP_PW20 = 'F300000002A3A6F2780272354F8B78F4D5FC11967BE65334';
  CN_SM9_FAST_EXP_PW21 = 'B640000002A3A6F0E303AB4FF2EB2052A9F02115CAEF75E70F738991676AF249';
  CN_SM9_FAST_EXP_PW22 = 'F300000002A3A6F2780272354F8B78F4D5FC11967BE65333';
  CN_SM9_FAST_EXP_PW23 = 'B640000002A3A6F0E303AB4FF2EB2052A9F02115CAEF75E70F738991676AF24A';

  // 签名私钥生成函数识别符
  CN_SM9_SIGNATURE_USER_HID = 1;

  // 密钥交换时的加密私钥生成函数识别符
  CN_SM9_KEY_EXCHANGE_USER_HID = 2;

  // 密钥封装的加密私钥生成函数识别符
  CN_SM9_KEY_ENCAPSULATION_USER_HID = 3;

  // 加密时的加密私钥生成函数识别符
  CN_SM9_ENCRYPTION_USER_HID = 3;

  // 密钥交换前后步骤中的两个前缀
  CN_SM9_KEY_EXCHANGE_HASHID1 = $82;
  CN_SM9_KEY_EXCHANGE_HASHID2 = $83;

type
  ECnSM9Exception = class(Exception);

  TCnFP2 = class
  {* 二次扩域大整系数元素实现类}
  private
    F0: TCnBigNumber;
    F1: TCnBigNumber;
    function GetItems(Index: Integer): TCnBigNumber;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    function IsZero: Boolean;
    function IsOne: Boolean;
    function SetZero: Boolean;
    function SetOne: Boolean;
    function SetU: Boolean;
    function SetBigNumber(const Num: TCnBigNumber): Boolean;
    function SetHex(const S0, S1: string): Boolean;
    function SetWord(Value: Cardinal): Boolean;
    function SetWords(Value0, Value1: Cardinal): Boolean;

    property Items[Index: Integer]: TCnBigNumber read GetItems; default;
  end;

  TCnFP2Pool = class(TCnMathObjectPool)
  {* 二次扩域大整系数元素池实现类，允许使用到二次扩域大整系数元素的地方自行创建池}
  protected
    function CreateObject: TObject; override;
  public
    function Obtain: TCnFP2; reintroduce;
    procedure Recycle(Num: TCnFP2); reintroduce;
  end;

  TCnFP4 = class
  {* 四次扩域大整系数元素实现类}
  private
    F0: TCnFP2;
    F1: TCnFP2;
    function GetItems(Index: Integer): TCnFP2;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    function IsZero: Boolean;
    function IsOne: Boolean;
    function SetZero: Boolean;
    function SetOne: Boolean;
    function SetU: Boolean;
    function SetV: Boolean;
    function SetBigNumber(const Num: TCnBigNumber): Boolean;
    function SetBigNumbers(const Num0, Num1: TCnBigNumber): Boolean;
    function SetHex(const S0, S1, S2, S3: string): Boolean;
    function SetWord(Value: Cardinal): Boolean;
    function SetWords(Value0, Value1, Value2, Value3: Cardinal): Boolean;

    property Items[Index: Integer]: TCnFP2 read GetItems; default;
  end;

  TCnFP4Pool = class(TCnMathObjectPool)
  {* 四次扩域大整系数元素池实现类，允许使用到四次扩域大整系数元素的地方自行创建池}
  protected
    function CreateObject: TObject; override;
  public
    function Obtain: TCnFP4; reintroduce;
    procedure Recycle(Num: TCnFP4); reintroduce;
  end;

  TCnFP12 = class
  {* 十二次扩域大整系数元素实现类}
  private
    F0: TCnFP4;
    F1: TCnFP4;
    F2: TCnFP4;
    function GetItems(Index: Integer): TCnFP4;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    function IsZero: Boolean;
    function IsOne: Boolean;
    function SetZero: Boolean;
    function SetOne: Boolean;
    function SetU: Boolean;
    function SetV: Boolean;
    function SetW: Boolean;
    function SetWSqr: Boolean;
    function SetBigNumber(const Num: TCnBigNumber): Boolean;
    function SetBigNumbers(const Num0, Num1, Num2: TCnBigNumber): Boolean;
    function SetHex(const S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11: string): Boolean;
      
    function SetWord(Value: Cardinal): Boolean;
    function SetWords(Value0, Value1, Value2, Value3, Value4, Value5, Value6,
      Value7, Value8, Value9, Value10, Value11: Cardinal): Boolean;

    property Items[Index: Integer]: TCnFP4 read GetItems; default;
  end;

  TCnFP12Pool = class(TCnMathObjectPool)
  {* 十二次扩域大整系数元素池实现类，允许使用到四次扩域大整系数元素的地方自行创建池}
  protected
    function CreateObject: TObject; override;
  public
    function Obtain: TCnFP12; reintroduce;
    procedure Recycle(Num: TCnFP12); reintroduce;
  end;

  TCnFP2Point = class(TPersistent)
  {* 普通坐标系里的 FP2 平面点，由两个坐标组成，这里不直接参与计算，均转换成仿射坐标系计算}
  private
    FX: TCnFP2;
    FY: TCnFP2;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* 转换为字符串}
    property X: TCnFP2 read FX;
    property Y: TCnFP2 read FY;
  end;

  TCnFP2AffinePoint = class
  {* 仿射坐标系里的 FP2 平面点，由三个坐标组成}
  private
    FX: TCnFP2;
    FY: TCnFP2;
    FZ: TCnFP2;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* 转换为字符串}
    procedure SetZero;
    {* 设置为全 0，似乎没啥用}
    function IsAtInfinity: Boolean;
    {* 是否位于无限远处}
    function SetToInfinity: Boolean;
    {* 坐标设为无限远}
    function GetCoordinatesFP2(const FP2X, FP2Y: TCnFP2): Boolean;
    {* 获取 XY 坐标值，内部采用复制}
    function SetCoordinatesFP2(const FP2X, FP2Y: TCnFP2): Boolean;
    {* 设置 XY 坐标值，内部采用复制}
    function SetCoordinatesHex(const SX0, SX1, SY0, SY1: string): Boolean;
    {* 设置 XY 坐标值，使用十六进制字符串}
    function SetCoordinatesBigNumbers(const X0, X1, Y0, Y1: TCnBigNumber): Boolean;
    {* 设置 XY 坐标值，使用大数对象，内部采用复制}
    function GetJacobianCoordinatesFP12(const FP12X, FP12Y: TCnFP12; Prime: TCnBigNumber): Boolean;
    {* 获取扩展 XY 坐标值，内部采用复制}
    function SetJacobianCoordinatesFP12(const FP12X, FP12Y: TCnFP12; Prime: TCnBigNumber): Boolean;
    {* 设置扩展 XY 坐标值，内部采用复制}
    function IsOnCurve(Prime: TCnBigNumber): Boolean;
    {* 判断是否在椭圆曲线 y^2 = x^3 + 5 上}

    property X: TCnFP2 read FX;
    property Y: TCnFP2 read FY;
    property Z: TCnFP2 read FZ;
  end;

  TCnFP2AffinePointPool = class(TCnMathObjectPool)
  {* 仿射坐标系里的平面点池实现类，允许使用到仿射坐标系里的平面点的地方自行创建池}
  protected
    function CreateObject: TObject; override;
  public
    function Obtain: TCnFP2AffinePoint; reintroduce;
    procedure Recycle(Num: TCnFP2AffinePoint); reintroduce;
  end;

// ============================ SM9 具体实现类 =================================

  TCnSM9SignatureMasterPrivateKey = class(TCnBigNumber);
  {* SM9 中的签名主私钥，随机生成}
  TCnSM9SignatureMasterPublicKey  = class(TCnFP2Point);
  {* SM9 中的签名主公钥，用签名主私钥乘以 G2 点而来}

  TCnSM9SignatureMasterKey = class
  {* SM9 中的签名主密钥，由 KGC 密钥管理中心生成，公钥可公开}
  private
    FPrivateKey: TCnSM9SignatureMasterPrivateKey;
    FPublicKey: TCnSM9SignatureMasterPublicKey;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    property PrivateKey: TCnSM9SignatureMasterPrivateKey read FPrivateKey;
    property PublicKey: TCnSM9SignatureMasterPublicKey read FPublicKey;
  end;

  TCnSM9SignatureUserPrivateKey = class(TCnEccPoint);
  {* SM9 中的用户签名私钥，由 KGC 密钥管理中心根据用户标识生成，无对应公钥
    或者说，用户验证签名时用的公钥就是用户标识与签名主公钥}

  TCnSM9Signature = class
  private
    FH: TCnBigNumber;
    FS: TCnEccPoint;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}

    property H: TCnBigNumber read FH;
    property S: TCnEccPoint read FS;
  end;

  TCnSM9EncryptionMasterPrivateKey = class(TCnBigNumber);
  {* SM9 中用于密钥封装与加解密的加密主私钥，随机生成}

  TCnSM9EncryptionMasterPublicKey = class(TCnEccPoint);
  {* SM9 中用于密钥封装与加解密的加密主公钥，用加密主私钥乘以 G1 点而来}

  TCnSM9EncryptionMasterKey = class
  {* SM9 中用于密钥封装与加解密的加密主密钥，由 KGC 密钥管理中心生成，公钥可公开}
  private
    FPrivateKey: TCnSM9EncryptionMasterPrivateKey;
    FPublicKey: TCnSM9EncryptionMasterPublicKey;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    property PrivateKey: TCnSM9EncryptionMasterPrivateKey read FPrivateKey;
    property PublicKey: TCnSM9EncryptionMasterPublicKey read FPublicKey;
  end;

  TCnSM9EncryptionUserPrivateKey = class(TCnFP2Point);
  {* SM9 中的用户加密私钥，用于密钥封装或加解密，由 KGC 密钥管理中心根据用户标识生成，无对应公钥
    或者说，用户解密时用的公钥就是用户标识与加密主公钥}

  TCnSM9KeyEncapsulationCode = class(TCnEccPoint);
  {* 密钥封装传输的内容}

  TCnSM9KeyEncapsulation = class
  {* 密钥封装结果类，注意往外传只需要传 Code}
  private
    FKey: AnsiString;
    FKeyLength: Integer;
    FCode: TCnSM9KeyEncapsulationCode;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}

    property KeyByteLength: Integer read FKeyLength;
    {* 密文的字节长度}
    property Key: AnsiString read FKey write FKey;
    {* 封装的密钥，无需往外传}
    property Code: TCnSM9KeyEncapsulationCode read FCode;
    {* 封装的密文，需要往外传}
  end;

  TCnSM9EncrytionMode = (semSM4, semXOR);
  {* SM9 公钥加密的两种模式，用 SM4 分组加密或 KDF 序列密码异或}

  TCnSM9KeyExchangeUserPrivateKey = class(TCnFP2Point);
  {* SM9 中的用户加密私钥，用于密钥交换，由 KGC 密钥管理中心根据用户标识生成，无对应公钥}

  TCnSM9KeyExchangeMasterPrivateKey = class(TCnBigNumber);
  {* SM9 中用于密钥交换的加密主私钥，随机生成}

  TCnSM9KeyExchangeMasterPublicKey = class(TCnEccPoint);
  {* SM9 中用于密钥交换的加密主公钥，用加密主私钥乘以 G1 点而来}

  TCnSM9KeyExchangeMasterKey = class
  {* SM9 中用于密钥交换的加密主密钥，由 KGC 密钥管理中心生成，公钥可公开}
  private
    FPrivateKey: TCnSM9KeyExchangeMasterPrivateKey;
    FPublicKey: TCnSM9KeyExchangeMasterPublicKey;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    property PrivateKey: TCnSM9KeyExchangeMasterPrivateKey read FPrivateKey;
    property PublicKey: TCnSM9KeyExchangeMasterPublicKey read FPublicKey;
  end;

  TCnSM9 = class(TCnEcc)
  {* SM9 内容封装类}
  private
    FGenerator2: TCnFP2Point;

  public
    constructor Create; reintroduce;
    destructor Destroy; override;

    property Generator2: TCnFP2Point read FGenerator2;
  end;

// ====================== 二次扩域大整系数元素运算函数 =========================

function FP2New: TCnFP2;
{* 创建一二次扩域大整系数元素对象，等同于 TCnFP2.Create}

procedure FP2Free(FP2: TCnFP2);
{* 释放一二次扩域大整系数元素对象，等同于 TCnFP2.Free}

function FP2IsZero(FP2: TCnFP2): Boolean;
{* 判断一二次扩域大整系数元素对象是否为 0}

function FP2IsOne(FP2: TCnFP2): Boolean;
{* 判断一二次扩域大整系数元素对象是否为 1}

function FP2SetZero(FP2: TCnFP2): Boolean;
{* 将一二次扩域大整系数元素对象设置为 0}

function FP2SetOne(FP2: TCnFP2): Boolean;
{* 将一二次扩域大整系数元素对象设置为 1，也就是 [0] 为 1，[1] 为 0}

function FP2SetU(FP2: TCnFP2): Boolean;
{* 将一二次扩域大整系数元素对象设为 U，也就是 [0] 为 0，[1] 为 1}

function FP2SetBigNumber(const FP2: TCnFP2; const Num: TCnBigNumber): Boolean;
{* 将一二次扩域大整系数元素对象设置为某一个大数}

function FP2SetBigNumbers(const FP2: TCnFP2; const Num0, Num1: TCnBigNumber): Boolean;
{* 将一二次扩域大整系数元素对象设置为两个大数值}

function FP2SetHex(const FP2: TCnFP2; const S0, S1: string): Boolean;
{* 将一二次扩域大整系数元素对象设置为两个十六进制字符串}

function FP2ToString(const FP2: TCnFP2): string;
{* 将一二次扩域大整系数元素对象转换为字符串}

function FP2SetWord(const FP2: TCnFP2; Value: Cardinal): Boolean;
{* 将一二次扩域大整系数元素对象设置为一个 Cardinal}

function FP2SetWords(const FP2: TCnFP2; Value0, Value1: Cardinal): Boolean;
{* 将一二次扩域大整系数元素对象设置为两个 Cardinal}

function FP2Equal(const F1, F2: TCnFP2): Boolean;
{* 判断两个二次扩域大整系数元素对象值是否相等}

function FP2Copy(const Dst, Src: TCnFP2): TCnFP2;
{* 将一二次扩域大整系数元素对象值复制到另一个二次扩域大整系数元素对象中}

function FP2Negate(const Res: TCnFP2; const F: TCnFP2; Prime: TCnBigNumber): Boolean;
{* 将一二次扩域大整系数元素对象值有限域中求负}

function FP2Add(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean;
{* 有限域中二次扩域大整系数元素加法，Prime 为域素数，Res 可以是 F1、F2，F1 可以是 F2}

function FP2Sub(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean;
{* 有限域中二次扩域大整系数元素减法，Prime 为域素数，Res 可以是 F1、F2，F1 可以是 F2}

function FP2Mul(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean; overload;
{* 有限域中二次扩域大整系数元素乘法，Prime 为域素数，Res 不可以是 F1 或 F2，F1 可以是 F2}

function FP2Mul3(const Res: TCnFP2; const F: TCnFP2; Prime: TCnBigNumber): Boolean;
{* 有限域中二次扩域大整系数元素对象乘以 3，Prime 为域素数，Res 可以是 F}

function FP2MulU(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean;
{* 有限域中二次扩域大整系数元素 U 乘法，Prime 为域素数，Res 不可以是 F1 或 F2，F1 可以是 F2}

function FP2Mul(const Res: TCnFP2; const F: TCnFP2; Num: TCnBigNumber; Prime: TCnBigNumber): Boolean; overload;
{* 有限域中二次扩域大整系数元素与大数的乘法，Prime 为域素数，Res 可以是 F，但 Num 不能是 Res 或 F 中的内容}

function FP2Inverse(const Res: TCnFP2; const F: TCnFP2; Prime: TCnBigNumber): Boolean;
{* 有限域中二次扩域大整系数元素求模反，Prime 为域素数，Res 可以是 F}

function FP2Div(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean;
{* 有限域中二次扩域大整系数元素除法，Prime 为域素数，Res 可以是 F1、F2，F1 可以是 F2，内部用模反乘法实现}

function FP2ToStream(FP2: TCnFP2; Stream: TStream; FixedLen: Integer = 0): Integer;
{* 将一二次扩域大整系数元素对象的内容写入流，返回写入长度}

// ====================== 四次扩域大整系数元素运算函数 =========================

function FP4New: TCnFP4;
{* 创建一四次扩域大整系数元素对象，等同于 TCnFP4.Create}

procedure FP4Free(FP4: TCnFP4);
{* 释放一四次扩域大整系数元素对象，等同于 TCnFP4.Free}

function FP4IsZero(FP4: TCnFP4): Boolean;
{* 判断一四次扩域大整系数元素对象是否为 0}

function FP4IsOne(FP4: TCnFP4): Boolean;
{* 判断一四次扩域大整系数元素对象是否为 1}

function FP4SetZero(FP4: TCnFP4): Boolean;
{* 将一四次扩域大整系数元素对象设置为 0}

function FP4SetOne(FP4: TCnFP4): Boolean;
{* 将一四次扩域大整系数元素对象设置为 1，也就是 [0] 为 1，[1] 为 0}

function FP4SetU(FP4: TCnFP4): Boolean;
{* 将一四次扩域大整系数元素对象设为 U，也就是 [0] 为 U，[1] 为 0}

function FP4SetV(FP4: TCnFP4): Boolean;
{* 将一四次扩域大整系数元素对象设为 V，也就是 [0] 为 0，[1] 为 1}

function FP4SetBigNumber(const FP4: TCnFP4; const Num: TCnBigNumber): Boolean;
{* 将一四次扩域大整系数元素对象设置为某一个大数}

function FP4SetBigNumbers(const FP4: TCnFP4; const Num0, Num1: TCnBigNumber): Boolean;
{* 将一四次扩域大整系数元素对象设置为两个大数值}

function FP4SetFP2(const FP4: TCnFP4; const FP2: TCnFP2): Boolean;
{* 将一四次扩域大整系数元素对象设置为一个二次扩域大整系数元素}

function FP4Set2FP2S(const FP4: TCnFP4; const FP20, FP21: TCnFP2): Boolean;
{* 将一四次扩域大整系数元素对象设置为两个二次扩域大整系数元素}

function FP4SetHex(const FP4: TCnFP4; const S0, S1, S2, S3: string): Boolean;
{* 将一四次扩域大整系数元素对象设置为四个十六进制字符串}

function FP4ToString(const FP4: TCnFP4): string;
{* 将一四次扩域大整系数元素对象转换为字符串}

function FP4SetWord(const FP4: TCnFP4; Value: Cardinal): Boolean;
{* 将一四次扩域大整系数元素对象设置为一个 Cardinal}

function FP4SetWords(const FP4: TCnFP4; Value0, Value1, Value2, Value3: Cardinal): Boolean;
{* 将一四次扩域大整系数元素对象设置为四个 Cardinal}

function FP4Equal(const F1, F2: TCnFP4): Boolean;
{* 判断两个四次扩域大整系数元素对象值是否相等}

function FP4Copy(const Dst, Src: TCnFP4): TCnFP4;
{* 将一四次扩域大整系数元素对象值复制到另一个四次扩域大整系数元素对象中}

function FP4Negate(const Res: TCnFP4; const F: TCnFP4; Prime: TCnBigNumber): Boolean;
{* 将一四次扩域大整系数元素对象值有限域中求负}

function FP4Add(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
{* 有限域中四次扩域大整系数元素加法，Prime 为域素数，Res 可以是 F1、F2，F1 可以是 F2}

function FP4Sub(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
{* 有限域中四次扩域大整系数元素减法，Prime 为域素数，Res 可以是 F1、F2，F1 可以是 F2}

function FP4Mul(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
{* 有限域中四次扩域大整系数元素乘法，Prime 为域素数，Res 不可以是 F1 或 F2，F1 可以是 F2}

function FP4Mul3(const Res: TCnFP4; const F: TCnFP4; Prime: TCnBigNumber): Boolean;
{* 有限域中四次扩域大整系数元素对象乘以 3，Prime 为域素数，Res 可以是 F}

function FP4MulV(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
{* 有限域中四次扩域大整系数元素 V 乘法，Prime 为域素数，Res 不可以是 F1 或 F2，F1 可以是 F2}

function FP4Inverse(const Res: TCnFP4; const F: TCnFP4; Prime: TCnBigNumber): Boolean;
{* 有限域中四次扩域大整系数元素求模反，Prime 为域素数，Res 可以是 F}

function FP4Div(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
{* 有限域中四次扩域大整系数元素除法，Prime 为域素数，Res 可以是 F1、F2，F1 可以是 F2，内部用模反乘法实现}

function FP4ToStream(FP4: TCnFP4; Stream: TStream; FixedLen: Integer = 0): Integer;
{* 将一四次扩域大整系数元素对象的内容写入流，返回写入长度}

// ===================== 十二次扩域大整系数元素运算函数 ========================

function FP12New: TCnFP12;
{* 创建一十二次扩域大整系数元素对象，等同于 TCnFP12.Create}

procedure FP12Free(FP12: TCnFP12);
{* 释放一十二次扩域大整系数元素对象，等同于 TCnFP12.Free}

function FP12IsZero(FP12: TCnFP12): Boolean;
{* 判断一十二次扩域大整系数元素对象是否为 0}

function FP12IsOne(FP12: TCnFP12): Boolean;
{* 判断一十二次扩域大整系数元素对象是否为 1}

function FP12SetZero(FP12: TCnFP12): Boolean;
{* 将一十二次扩域大整系数元素对象设置为 0}

function FP12SetOne(FP12: TCnFP12): Boolean;
{* 将一十二次扩域大整系数元素对象设置为 1}

function FP12SetU(FP12: TCnFP12): Boolean;
{* 将一十二次扩域大整系数元素对象设为 U，也就是仨 FP4 分别 U、0、0}

function FP12SetV(FP12: TCnFP12): Boolean;
{* 将一十二次扩域大整系数元素对象设为 V，也就是仨 FP4 分别 V、0、0}

function FP12SetW(FP12: TCnFP12): Boolean;
{* 将一十二次扩域大整系数元素对象设为 W，也就是仨 FP4 分别 0、1、0}

function FP12SetWSqr(FP12: TCnFP12): Boolean;
{* 将一十二次扩域大整系数元素对象设为 W^2，也就是仨 FP4 分别 0、0、1}

function FP12SetBigNumber(const FP12: TCnFP12; const Num: TCnBigNumber): Boolean;
{* 将一十二次扩域大整系数元素对象设置为某一个大数}

function FP12SetBigNumbers(const FP12: TCnFP12; const Num0, Num1, Num2: TCnBigNumber): Boolean;
{* 将一十二次扩域大整系数元素对象设置为三个大数值}

function FP12SetFP4(const FP12: TCnFP12; const FP4: TCnFP4): Boolean;
{* 将一十二次扩域大整系数元素对象设置为一个四次扩域大整系数元素}

function FP12Set3FP4S(const FP12: TCnFP12; const FP40, FP41, FP42: TCnFP4): Boolean;
{* 将一十二次扩域大整系数元素对象设置为三个四次扩域大整系数元素}

function FP12SetFP2(const FP12: TCnFP12; const FP2: TCnFP2): Boolean;
{* 将一十二次扩域大整系数元素对象设置为一个二次扩域大整系数元素}

function FP12SetHex(const FP12: TCnFP12; const S0, S1, S2, S3, S4, S5, S6, S7, S8,
  S9, S10, S11: string): Boolean;
{* 将一十二次扩域大整系数元素对象设置为十二个十六进制字符串}

function FP12ToString(const FP12: TCnFP12): string;
{* 将一十二次扩域大整系数元素对象转换为字符串}

function FP12SetWord(const FP12: TCnFP12; Value: Cardinal): Boolean;
{* 将一十二次扩域大整系数元素对象设置为一个 Cardinal}

function FP12SetWords(const FP12: TCnFP12; Value0, Value1, Value2, Value3, Value4,
  Value5, Value6, Value7, Value8, Value9, Value10, Value11: Cardinal): Boolean;
{* 将一十二次扩域大整系数元素对象设置为十二个 Cardinal}

function FP12Equal(const F1, F2: TCnFP12): Boolean;
{* 判断两个十二次扩域大整系数元素对象值是否相等}

function FP12Copy(const Dst, Src: TCnFP12): TCnFP12;
{* 将一十二次扩域大整系数元素对象值复制到另一个十二次扩域大整系数元素对象中}

function FP12Negate(const Res: TCnFP12; const F: TCnFP12; Prime: TCnBigNumber): Boolean;
{* 将一十二次扩域大整系数元素对象值有限域中求负}

function FP12Add(const Res: TCnFP12; const F1, F2: TCnFP12; Prime: TCnBigNumber): Boolean;
{* 有限域中十二次扩域大整系数元素加法，Prime 为域素数，Res 可以是 F1、F2，F1 可以是 F2}

function FP12Sub(const Res: TCnFP12; const F1, F2: TCnFP12; Prime: TCnBigNumber): Boolean;
{* 有限域中十二次扩域大整系数元素减法，Prime 为域素数，Res 可以是 F1、F2，F1 可以是 F2}

function FP12Mul(const Res: TCnFP12; const F1, F2: TCnFP12; Prime: TCnBigNumber): Boolean;
{* 有限域中十二次扩域大整系数元素乘法，Prime 为域素数，Res 不可以是 F1 或 F2，F1 可以是 F2}

function FP12Mul3(const Res: TCnFP12; const F: TCnFP12; Prime: TCnBigNumber): Boolean;
{* 有限域中十二次扩域大整系数元素对象乘以 3，Prime 为域素数，Res 可以是 F}

function FP12Inverse(const Res: TCnFP12; const F: TCnFP12; Prime: TCnBigNumber): Boolean;
{* 有限域中十二次扩域大整系数元素求模反，Prime 为域素数，Res 可以是 F}

function FP12Div(const Res: TCnFP12; const F1, F2: TCnFP12; Prime: TCnBigNumber): Boolean;
{* 有限域中十二次扩域大整系数元素除法，Prime 为域素数，Res 可以是 F1、F2，F1 可以是 F2，内部用模反乘法实现}

function FP12Power(const Res: TCnFP12; const F: TCnFP12; Exponent: TCnBigNumber; Prime: TCnBigNumber): Boolean;
{* 有限域中十二次扩域大整系数元素乘方，Prime 为域素数，Res 可以是 F}

function FP12ToStream(FP12: TCnFP12; Stream: TStream; FixedLen: Integer = 0): Integer;
{* 将一十二次扩域大整系数元素对象的内容写入流，返回写入长度}

// ===================== 仿射坐标系里的三元点的运算函数 ========================

function FP2AffinePointNew: TCnFP2AffinePoint;
{* 创建一仿射坐标系里的三元点对象，等同于 TCnAffinePoint.Create}

procedure AffinePointFree(P: TCnFP2AffinePoint);
{* 释放一仿射坐标系里的三元点对象，等同于 TCnAffinePoint.Free}

function FP2AffinePointSetZero(P: TCnFP2AffinePoint): Boolean;
{* 将一个仿射坐标系里的三元点坐标设置为全 0}

function FP2AffinePointToString(const P: TCnFP2AffinePoint): string;
{* 将一仿射坐标系里的三元点对象转换为字符串}

function FP2AffinePointEqual(const P1, P2: TCnFP2AffinePoint): Boolean;
{* 判断两个仿射坐标系里的三元点对象值是否相等}

function FP2AffinePointCopy(const Dst, Src: TCnFP2AffinePoint): TCnFP2AffinePoint;
{* 将一仿射坐标系里的三元点对象值复制到另一个仿射坐标系里的三元点对象中}

function FP2AffinePointIsAtInfinity(const P: TCnFP2AffinePoint): Boolean;
{* 判断一仿射坐标系里的三元点对象是否位于无限远处}

function FP2AffinePointSetToInfinity(const P: TCnFP2AffinePoint): Boolean;
{* 将一仿射坐标系里的三元点对象坐标设为无限远}

function FP2AffinePointGetCoordinates(const P: TCnFP2AffinePoint; const FP2X, FP2Y: TCnFP2): Boolean;
{* 获取一仿射坐标系里的三元点对象的 XY 坐标值，内部采用复制}

function FP2AffinePointSetCoordinates(const P: TCnFP2AffinePoint; const FP2X, FP2Y: TCnFP2): Boolean;
{* 设置一仿射坐标系里的三元点对象的 XY 坐标值，内部采用复制}

function FP2AffinePointSetCoordinatesHex(const P: TCnFP2AffinePoint;
  const SX0, SX1, SY0, SY1: string): Boolean;
{* 设置一仿射坐标系里的三元点对象的 XY 坐标值，使用十六进制字符串}

function FP2AffinePointSetCoordinatesBigNumbers(const P: TCnFP2AffinePoint;
  const X0, X1, Y0, Y1: TCnBigNumber): Boolean;
{* 设置一仿射坐标系里的三元点对象的 XY 坐标值，使用大数对象，内部采用复制}

function FP2AffinePointGetJacobianCoordinates(const P: TCnFP2AffinePoint;
  const FP12X, FP12Y: TCnFP12; Prime: TCnBigNumber): Boolean;
{* 获取一仿射坐标系里的三元点对象的雅可比 XY 坐标值，内部采用复制}

function FP2AffinePointSetJacobianCoordinates(const P: TCnFP2AffinePoint;
  const FP12X, FP12Y: TCnFP12; Prime: TCnBigNumber): Boolean;
{* 设置一仿射坐标系里的三元点对象的雅可比 XY 坐标值，内部采用复制}

function FP2AffinePointIsOnCurve(const P: TCnFP2AffinePoint; Prime: TCnBigNumber): Boolean;
{* 判断一仿射坐标系里的三元点对象是否在椭圆曲线 y^2 = x^3 + 5 上}

function FP2AffinePointNegate(const Res: TCnFP2AffinePoint; const P: TCnFP2AffinePoint;
  Prime: TCnBigNumber): Boolean;
{* 一个仿射坐标系里的三元点对象的椭圆曲线求反，Res 可以是 P}

function FP2AffinePointDouble(const Res: TCnFP2AffinePoint; const P: TCnFP2AffinePoint;
  Prime: TCnBigNumber): Boolean;
{* 一个仿射坐标系里的三元点对象的椭圆曲线倍点法，Res 可以是 P}

function FP2AffinePointAdd(const Res: TCnFP2AffinePoint; const P, Q: TCnFP2AffinePoint;
  Prime: TCnBigNumber): Boolean;
{* 两个仿射坐标系里的三元点对象的椭圆曲线加法，Res 可以是 P 或 Q，P 可以是 Q，
  注意内部还是将 Z 当成 1，仍然是求反的普通操作}

function FP2AffinePointSub(const Res: TCnFP2AffinePoint; const P, Q: TCnFP2AffinePoint;
  Prime: TCnBigNumber): Boolean;
{* 两个仿射坐标系里的三元点对象的椭圆曲线减法，Res 可以是 P 或 Q，P 可以是 Q}

function FP2AffinePointMul(const Res: TCnFP2AffinePoint; const P: TCnFP2AffinePoint;
  Num: TCnBigNumber; Prime: TCnBigNumber): Boolean;
{* 一个仿射坐标系里的三元点对象的椭圆曲线 N 倍点法，Res 可以是 P}

function FP2AffinePointFrobenius(const Res: TCnFP2AffinePoint; const P: TCnFP2AffinePoint;
  Prime: TCnBigNumber): Boolean;
{* 计算一个仿射坐标系里的三元点对象的弗罗贝尼乌斯自同态值，Res 可以是 P
  其实就是 P 的 Prime 次方的结果 mod Prime}

function FP2PointToString(const P: TCnFP2Point): string;
{* 将一仿射坐标系里的二元点 FP2 对象转换为字符串}

function FP2AffinePointToFP2Point(FP2P: TCnFP2Point; FP2AP: TCnFP2AffinePoint;
  Prime: TCnBigNumber): Boolean;
{* 将一仿射坐标系里的三元点 FP2 对象转换为普通坐标系里的二元点 FP2 对象}

function FP2PointToFP2AffinePoint(FP2AP: TCnFP2AffinePoint; FP2P: TCnFP2Point): Boolean;
{* 将一仿射坐标系里的三元点 FP2 对象转换为普通坐标系里的二元点 FP2 对象}

// ============================ 双线性对计算函数 ===============================

function Rate(const F: TCnFP12; const Q: TCnFP2AffinePoint; const XP, YP: TCnBigNumber;
  const A: TCnBigNumber; const K: TCnBigNumber; Prime: TCnBigNumber): Boolean;
{* 计算 R-ate 对。输出是一个 FP12 值，输入是一个 BN 曲线上的点的坐标 XP、YP，
  一个 FP2 上的 XYZ 仿射坐标点，一个指数 K、一个循环次数 A}

function SM9RatePairing(const F: TCnFP12; const Q: TCnFP2AffinePoint; const P: TCnEccPoint): Boolean;
{* 根据 SM9 指定的 BN 曲线的参数以及指定点计算 R-ate 对，输入为一个 BN 曲线上的点
  一个 FP2 上的 XYZ 仿射坐标点，输出为一个 FP12 值}

// ===================== SM9 具体实现函数：签名与验证 ==========================

function CnSM9KGCGenerateSignatureMasterKey(SignatureMasterKey:
  TCnSM9SignatureMasterKey; SM9: TCnSM9 = nil): Boolean;
{* 由 KCG 调用，生成签名主密钥}

function CnSM9KGCGenerateSignatureUserKey(SignatureMasterPrivateKey:
  TCnSM9SignatureMasterPrivateKey; const AUserID: AnsiString;
  OutSignatureUserPrivateKey: TCnSM9SignatureUserPrivateKey; SM9: TCnSM9 = nil): Boolean;
{* 由 KCG 调用，根据用户 ID 生成用户签名私钥}

function CnSM9UserSignData(SignatureMasterPublicKey: TCnSM9SignatureMasterPublicKey;
  SignatureUserPrivateKey: TCnSM9SignatureUserPrivateKey; PlainData: Pointer;
  DataLen: Integer; OutSignature: TCnSM9Signature; SM9: TCnSM9 = nil): Boolean;
{* 利用用户签名私钥与用户 ID 对数据进行签名，返回成功与否，签名值放在 OutSignature 中
  注意因有用户私钥存在，用户 ID 无需参与签名}

function CnSM9UserVerifyData(const AUserID: AnsiString; PlainData: Pointer; DataLen: Integer;
  InSignature: TCnSM9Signature; SignatureMasterPublicKey: TCnSM9SignatureMasterPublicKey;
  SM9: TCnSM9 = nil): Boolean;
{* 利用公开的签名公钥与用户 ID 对数据与签名进行验证，返回验证签名成功与否
  注意用户 ID 需要参与签名验证}

// ================== SM9 具体实现函数：加解密与密钥封装 =======================

function CnSM9KGCGenerateEncryptionMasterKey(EncryptionMasterKey:
  TCnSM9EncryptionMasterKey; SM9: TCnSM9 = nil): Boolean;
{* 由 KCG 调用，生成加密主密钥，可用于加解密或密钥封装}

function CnSM9KGCGenerateEncryptionUserKey(EncryptionMasterPrivateKey:
  TCnSM9EncryptionMasterPrivateKey; const AUserID: AnsiString;
  OutEncryptionUserKey: TCnSM9EncryptionUserPrivateKey; SM9: TCnSM9 = nil): Boolean;
{* 由 KCG 调用，根据用户 ID 生成用户加密私钥，可用于加解密或密钥封装}

// ====================== SM9 具体实现函数：密钥封装 ===========================

function CnSM9UserSendKeyEncapsulation(const DestUserID: AnsiString; KeyByteLength: Integer;
 EncryptionPublicKey: TCnSM9EncryptionMasterPublicKey;
 OutKeyEncapsulation: TCnSM9KeyEncapsulation; SM9: TCnSM9 = nil): Boolean;
{* 普通用户根据目标用户的 ID 与加密主公钥，生成 KeyLength 长度的字节串密钥封装内容，
  返回封装是否成功}

function CnSM9UserReceiveKeyEncapsulation(const DestUserID: AnsiString;
  EncryptionUserKey: TCnSM9EncryptionUserPrivateKey; KeyByteLength: Integer;
  InKeyEncapsulationC: TCnSM9KeyEncapsulationCode; out Key: AnsiString; SM9: TCnSM9 = nil): Boolean;
{* 目标用户根据自身的 ID 与用户加密私钥钥，从 KeyEncapsulation 对象中还原 KeyLength
  长度的字节串密钥封装内容放在 Key 中，返回解封是否成功}

// ======================= SM9 具体实现函数：加解密 ============================

function CnSM9UserEncryptData(const DestUserID: AnsiString;
  EncryptionPublicKey: TCnSM9EncryptionMasterPublicKey; PlainData: Pointer;
  DataLen: Integer; K1ByteLength, K2ByteLength: Integer; OutStream: TStream;
  EncryptionMode: TCnSM9EncrytionMode = semSM4; SM9: TCnSM9 = nil): Boolean;
{* 使用加密主公钥与目标用户的 ID 加密数据并写入流，返回加密是否成功，
  EncryptionMode 是 SM4 时 K1Length 参数值忽略，内部固定为 16 字节，
  SM4 使用 ECB 模式与 PKCS7 对齐}

function CnSM9UserDecryptData(const DestUserID: AnsiString;
  EncryptionUserKey: TCnSM9EncryptionUserPrivateKey; EnData: Pointer;
  DataLen: Integer; K2ByteLength: Integer; OutStream: TStream;
  EncryptionMode: TCnSM9EncrytionMode = semSM4; SM9: TCnSM9 = nil): Boolean;
{* 使用用户加密私钥解密数据并写入流，返回解密是否成功}

// ====================== SM9 具体实现函数：密钥交换 ===========================

function CnSM9KGCGenerateKeyExchangeMasterKey(KeyExchangeMasterKey:
  TCnSM9KeyExchangeMasterKey; SM9: TCnSM9 = nil): Boolean;
{* 由 KCG 调用，生成加密主密钥，可用于密钥交换，行为等同于 CnSM9KGCGenerateEncryptionMasterKey}

function CnSM9KGCGenerateKeyExchangeUserKey(KeyExchangeMasterPrivateKey:
  TCnSM9KeyExchangeMasterPrivateKey; const AUserID: AnsiString;
  OutKeyExchangeUserKey: TCnSM9KeyExchangeUserPrivateKey; SM9: TCnSM9 = nil): Boolean;
{* 由 KCG 调用，根据用户 ID 生成用于密钥交换的用户加密私钥}

function CnSM9UserKeyExchangeAStep1(const BUserID: AnsiString; KeyByteLength: Integer;
  KeyExchangePublicKey: TCnSM9KeyExchangeMasterPublicKey; OutRA: TCnEccPoint;
  OutRandA: TCnBigNumber; SM9: TCnSM9 = nil): Boolean;
{* 密钥交换第一步，A 用 B 的 ID 以及加密主公钥生成一个椭圆曲线点 RA 给 B
  同时记录中间计算结果 OutRandA，需要外部传入保存其值，在第三步中使用}

function CnSM9UserKeyExchangeBStep1(const AUserID, BUserID: AnsiString;
  KeyByteLength: Integer; KeyExchangePublicKey: TCnSM9KeyExchangeMasterPublicKey;
  KeyExchangeBUserKey: TCnSM9KeyExchangeUserPrivateKey; InRA: TCnEccPoint;
  OutRB: TCnEccPoint; out KeyB: AnsiString; out OutOptionalSB: TSM3Digest;
  OutG1, OutG2, OutG3: TCnFP12; SM9: TCnSM9 = nil): Boolean;
{* 密钥交换第二步，B 用 A、B 的 ID 以及加密主公钥与自己的私钥，根据所密钥长度与 RA
  生成协商密钥 KeyB。另外生成另一个椭圆曲线点 RB 再加上一个可选的校验结果 SB 给 A
  同时记录 OutG1, OutG2, OutG3 三个中间计算结果，需要外部传入保存其值，在第四步中使用}

function CnSM9UserKeyExchangeAStep2(const AUserID, BUserID: AnsiString; KeyByteLength: Integer;
  KeyExchangePublicKey: TCnSM9KeyExchangeMasterPublicKey;
  KeyExchangeAUserKey: TCnSM9KeyExchangeUserPrivateKey; InRandA: TCnBigNumber;
  InRA, InRB: TCnEccPoint; InOptionalSB: TSM3Digest; out KeyA: AnsiString;
  out OutOptionalSA: TSM3Digest; SM9: TCnSM9 = nil): Boolean;
{* 密钥交换第三步，A 用 B 的 ID 以及加密主公钥与自己的私钥，根据所密钥长度与 RA、RB
  生成协商密钥 KeyA，以及一个可选的校验结果 SA 给 B，此处 KeyA 应当等于 KeyB}

function CnSM9UserKeyExchangeBStep2(const AUserID, BUserID: AnsiString;
  InRA, InRB: TCnEccPoint; InOptionalSA: TSM3Digest; InG1, InG2, InG3: TCnFP12;
  SM9: TCnSM9 = nil): Boolean;
{* 密钥交换第四步，可选。B 用 A、B 的 ID 以及第二步中的三个中间结果，根据 RA、RB
  计算出校验结果并与 InOptionalSA 比较，不通过则校验失败}

// =================== SM9 具体实现函数：两种 Hash 算法 ========================

function CnSM9Hash1(const Res: TCnBigNumber; Data: Pointer; DataLen: Integer;
  N: TCnBigNumber): Boolean;
{* SM9 中规定的第一个密码函数，内部使用 SM3，256 位的散列函数
  输入为比特串 Data 与大数 N，输出为 1 至 N - 1 闭区间内的大数，N 应该传 SM9.Order}

function CnSM9Hash2(const Res: TCnBigNumber; Data: Pointer; DataLen: Integer;
  N: TCnBigNumber): Boolean;
{* SM9 中规定的第二个密码函数，内部使用 SM3，256 位的散列函数
  输入为比特串 Data 与大数 N，输出为 1 至 N - 1 闭区间内的大数，N 应该传 SM9.Order}

function SM9Mac(Key: Pointer; KeyByteLength: Integer; Z: Pointer; ZByteLength: Integer): TSM3Digest;
{* 根据密钥 Key 与消息 Z，求消息认证码}

implementation

uses
  CnKDF, CnSM4;

resourcestring
  SListIndexError = 'List Index Out of Bounds (%d)';
  SDivByZero = 'Division by Zero';
  SErrorMacParams = 'Error Mac Params';
  SSigMasterKeyZero = 'Signature Master Key Zero';
  SEncMasterKeyZero = 'Encryption Master Key Zero';

const
  CRLF = #13#10;

  CN_SM9_HASH_PREFIX_1 = 1;
  CN_SM9_HASH_PREFIX_2 = 2;

  CN_SM3_DIGEST_BITS = SizeOf(TSM3Digest) * 8;

var
  FLocalBigNumberPool: TCnBigNumberPool = nil;
  FLocalFP2Pool: TCnFP2Pool = nil;
  FLocalFP4Pool: TCnFP4Pool = nil;
  FLocalFP12Pool: TCnFP12Pool = nil;
  FLocalFP2AffinePointPool: TCnFP2AffinePointPool = nil;

  // SM9 运算的相关常数
  FSM9FiniteFieldSize: TCnBigNumber = nil;
  FSM9Order: TCnBigNumber = nil;
  FSM9K: Integer = 12;
  FSM9G1P1X: TCnBigNumber = nil;
  FSM9G1P1Y: TCnBigNumber = nil;
  FSM9G2P2X0: TCnBigNumber = nil;
  FSM9G2P2X1: TCnBigNumber = nil;
  FSM9G2P2Y0: TCnBigNumber = nil;
  FSM9G2P2Y1: TCnBigNumber = nil;
  FSM96TPlus2: TCnBigNumber = nil;
  FSM9FastExpP3: TCnBigNumber = nil;
  FFP12FastExpPW20: TCnBigNumber = nil;
  FFP12FastExpPW21: TCnBigNumber = nil;
  FFP12FastExpPW22: TCnBigNumber = nil;
  FFP12FastExpPW23: TCnBigNumber = nil;

// ====================== 二次扩域大整系数元素运算函数 =========================

function FP2New: TCnFP2;
begin
  Result := TCnFP2.Create;
end;

procedure FP2Free(FP2: TCnFP2);
begin
  FP2.Free;
end;

function FP2IsZero(FP2: TCnFP2): Boolean;
begin
  Result := FP2[0].IsZero and FP2[1].IsZero;
end;

function FP2IsOne(FP2: TCnFP2): Boolean;
begin
  Result := FP2[0].IsOne and FP2[1].IsZero;
end;

function FP2SetZero(FP2: TCnFP2): Boolean;
begin
  Result := False;
  if not FP2[0].SetZero then Exit;
  if not FP2[1].SetZero then Exit;
  Result := True;
end;

function FP2SetOne(FP2: TCnFP2): Boolean;
begin
  Result := False;
  if not FP2[0].SetOne then Exit;
  if not FP2[1].SetZero then Exit;
  Result := True;
end;

function FP2SetU(FP2: TCnFP2): Boolean;
begin
  Result := False;
  if not FP2[0].SetZero then Exit;
  if not FP2[1].SetOne then Exit;
  Result := True;
end;

function FP2SetBigNumber(const FP2: TCnFP2; const Num: TCnBigNumber): Boolean;
begin
  Result := False;
  if BigNumberCopy(FP2[0], Num) = nil then Exit;
  if not FP2[1].SetZero then Exit;
  Result := True;
end;

function FP2SetBigNumbers(const FP2: TCnFP2; const Num0, Num1: TCnBigNumber): Boolean;
begin
  Result := False;
  if BigNumberCopy(FP2[0], Num0) = nil then Exit;
  if BigNumberCopy(FP2[1], Num1) = nil then Exit;
  Result := True;
end;

function FP2SetHex(const FP2: TCnFP2; const S0, S1: string): Boolean;
begin
  Result := False;
  if not FP2[0].SetHex(S0) then Exit;
  if not FP2[1].SetHex(S1) then Exit;
  Result := True;
end;

function FP2ToString(const FP2: TCnFP2): string;
begin
  Result := FP2[1].ToHex + ',' + FP2[0].ToHex;
end;

function FP2SetWord(const FP2: TCnFP2; Value: Cardinal): Boolean;
begin
  Result := False;
  if not FP2[0].SetWord(Value) then Exit;
  if not FP2[1].SetZero then Exit;
  Result := True;
end;

function FP2SetWords(const FP2: TCnFP2; Value0, Value1: Cardinal): Boolean;
begin
  Result := False;
  if not FP2[0].SetWord(Value0) then Exit;
  if not FP2[1].SetWord(Value1) then Exit;
  Result := True;
end;

function FP2Equal(const F1, F2: TCnFP2): Boolean;
begin
  Result := BigNumberEqual(F1[0], F2[0]) and BigNumberEqual(F1[1], F2[1]);
end;

function FP2Copy(const Dst, Src: TCnFP2): TCnFP2;
begin
  Result := nil;
  if BigNumberCopy(Dst[0], Src[0]) = nil then Exit;
  if BigNumberCopy(Dst[1], Src[1]) = nil then Exit;
  Result := Dst;
end;

function FP2Negate(const Res: TCnFP2; const F: TCnFP2; Prime: TCnBigNumber): Boolean;
begin
  Result := False;
  if not BigNumberSub(Res[0], Prime, F[0]) then Exit;
  if not BigNumberSub(Res[1], Prime, F[1]) then Exit;
  if not BigNumberNonNegativeMod(Res[0], Res[0], Prime) then Exit;
  if not BigNumberNonNegativeMod(Res[1], Res[1], Prime) then Exit;
  Result := True;
end;

function FP2Add(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean;
begin
  Result := False;
  if not BigNumberAdd(Res[0], F1[0], F2[0]) then Exit;
  if not BigNumberAdd(Res[1], F1[1], F2[1]) then Exit;
  if not BigNumberNonNegativeMod(Res[0], Res[0], Prime) then Exit;
  if not BigNumberNonNegativeMod(Res[1], Res[1], Prime) then Exit;
  Result := True;
end;

function FP2Sub(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean;
begin
  Result := False;
  if not BigNumberSub(Res[0], F1[0], F2[0]) then Exit;
  if not BigNumberSub(Res[1], F1[1], F2[1]) then Exit;
  if not BigNumberNonNegativeMod(Res[0], Res[0], Prime) then Exit;
  if not BigNumberNonNegativeMod(Res[1], Res[1], Prime) then Exit;
  Result := True;
end;

function FP2Mul(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean;
var
  T0, T1, R0: TCnBigNumber;
begin
  Result := False;

  // r0 = a0 * b0 - 2 * a1 * b1
  // r1 = a0 * b1 + a1 * b0
  T0 := nil;
  T1 := nil;
  R0 := nil;

  try
    T0 := FLocalBigNumberPool.Obtain;
    T1 := FLocalBigNumberPool.Obtain;
    R0 := FLocalBigNumberPool.Obtain;

    if not BigNumberMul(T0, F1[0], F2[0]) then Exit;
    if not BigNumberMul(T1, F1[1], F2[1]) then Exit;
    if not BigNumberAdd(T1, T1, T1) then Exit;
    if not BigNumberSub(T0, T0, T1) then Exit;
    if not BigNumberNonNegativeMod(R0, T0, Prime) then Exit; // 不能直接给 Res[0] 赋值，万一 F1 和 Res 相同则会提前影响 F0

    if not BigNumberMul(T0, F1[0], F2[1]) then Exit;
    if not BigNumberMul(T1, F1[1], F2[0]) then Exit;
    if not BigNumberAdd(T1, T0, T1) then Exit;
    if not BigNumberNonNegativeMod(Res[1], T1, Prime) then Exit;

    if BigNumberCopy(Res[0], R0) = nil then Exit;
    Result := True;
  finally
    FLocalBigNumberPool.Recycle(R0);
    FLocalBigNumberPool.Recycle(T1);
    FLocalBigNumberPool.Recycle(T0);
  end;
end;

function FP2Mul3(const Res: TCnFP2; const F: TCnFP2; Prime: TCnBigNumber): Boolean;
var
  T: TCnFP2;
begin
  Result := False;
  T := FLocalFP2Pool.Obtain;
  try
    if not FP2Add(T, F, F, Prime) then Exit;
    if not FP2Add(Res, T, F, Prime) then Exit;
    Result := True;
  finally
    FLocalFP2Pool.Recycle(T);
  end;
end;

function FP2MulU(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean;
var
  T0, T1: TCnBigNumber;
begin
  Result := False;

  // r0 = -2 * (a0 * b1 + a1 * b0)
  // r1 = a0 * b0 - 2 * a1 * b1
  T0 := nil;
  T1 := nil;
  try
    T0 := FLocalBigNumberPool.Obtain;
    T1 := FLocalBigNumberPool.Obtain;

    if not BigNumberMul(T0, F1[0], F2[1]) then Exit;
    if not BigNumberMul(T1, F1[1], F2[0]) then Exit;
    if not BigNumberAdd(T0, T0, T1) then Exit;
    if not T0.MulWord(2) then Exit;
    T0.Negate;
    if not BigNumberNonNegativeMod(Res[0], T0, Prime) then Exit;

    if not BigNumberMul(T0, F1[0], F2[0]) then Exit;
    if not BigNumberMul(T1, F1[1], F2[1]) then Exit;
    if not T1.MulWord(2) then Exit;
    if not BigNumberSub(T1, T0, T1) then Exit;
    if not BigNumberNonNegativeMod(Res[1], T1, Prime) then Exit;
    Result := True;
  finally
    FLocalBigNumberPool.Recycle(T1);
    FLocalBigNumberPool.Recycle(T0);
  end;
end;

function FP2Mul(const Res: TCnFP2; const F: TCnFP2; Num: TCnBigNumber; Prime: TCnBigNumber): Boolean;
begin
  Result := False;
  if not BigNumberMul(Res[0], F[0], Num) then Exit;
  if not BigNumberMul(Res[1], F[1], Num) then Exit;
  if not BigNumberNonNegativeMod(Res[0], Res[0], Prime) then Exit;
  if not BigNumberNonNegativeMod(Res[1], Res[1], Prime) then Exit;
  Result := True;
end;

function FP2Inverse(const Res: TCnFP2; const F: TCnFP2; Prime: TCnBigNumber): Boolean;
var
  K, T: TCnBigNumber;
begin
  Result := False;
  if F[0].IsZero then
  begin
    if not Res[0].SetZero then Exit;
    // r1 = -((2 * a1)^-1) */
    if not BigNumberAdd(Res[1], F[1], F[1]) then Exit;
    BigNumberModularInverse(Res[1], Res[1], Prime);
    if not BigNumberNonNegativeMod(Res[1], Res[1], Prime) then Exit;
    if not BigNumberSub(Res[1], Prime, Res[1]) then Exit;
    Result := True;
  end
  else if F[1].IsZero then
  begin
    if not Res[1].SetZero then Exit;
    // r0 = a0^-1
    BigNumberModularInverse(Res[0], F[0], Prime);
    Result := True;
  end
  else
  begin
    // k = (a[0]^2 + 2 * a[1]^2)^-1
    // r[0] = a[0] * k
    // r[1] = -a[1] * k
    K := nil;
    T := nil;
    try
      K := FLocalBigNumberPool.Obtain;
      T := FLocalBigNumberPool.Obtain;

      if not BigNumberMul(T, F[1], F[1]) then Exit;
      if not T.MulWord(2) then Exit;
      if not BigNumberMul(K, F[0], F[0]) then Exit;
      if not BigNumberAdd(K, T, K) then Exit;
      BigNumberModularInverse(K, K, Prime);

      if not BigNumberMul(Res[0], F[0], K) then Exit;
      if not BigNumberNonNegativeMod(Res[0], Res[0], Prime) then Exit;

      if not BigNumberMul(Res[1], F[1], K) then Exit;
      if not BigNumberNonNegativeMod(Res[1], Res[1], Prime) then Exit;
      if not BigNumberSub(Res[1], Prime, Res[1]) then Exit;
      Result := True;
    finally
      FLocalBigNumberPool.Recycle(T);
      FLocalBigNumberPool.Recycle(K);
    end;
  end;
end;

function FP2Div(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean;
var
  Inv: TCnFP2;
begin
  Result := False;
  if F2.IsZero then
    raise EZeroDivide.Create(SDivByZero);

  if F1 = F2 then
  begin
    if not Res.SetOne then Exit;
    Result := True;
  end
  else
  begin
    Inv := FLocalFP2Pool.Obtain;
    try
      if not FP2Inverse(Inv, F2, Prime) then Exit;
      if not FP2Mul(Res, F1, Inv, Prime) then Exit;
      Result := True;
    finally
      FLocalFP2Pool.Recycle(Inv);
    end;
  end;
end;

function FP2ToStream(FP2: TCnFP2; Stream: TStream; FixedLen: Integer): Integer;
begin
  Result := BigNumberWriteBinaryToStream(FP2[1], Stream, FixedLen)
    + BigNumberWriteBinaryToStream(FP2[0], Stream, FixedLen);
end;

// ====================== 四次扩域大整系数元素运算函数 =========================

function FP4New: TCnFP4;
begin
  Result := TCnFP4.Create;
end;

procedure FP4Free(FP4: TCnFP4);
begin
  FP4.Free;
end;

function FP4IsZero(FP4: TCnFP4): Boolean;
begin
  Result := FP4[0].IsZero and FP4[1].IsZero;
end;

function FP4IsOne(FP4: TCnFP4): Boolean;
begin
  Result := FP4[0].IsOne and FP4[1].IsZero;
end;

function FP4SetZero(FP4: TCnFP4): Boolean;
begin
  Result := False;
  if not FP4[0].SetZero then Exit;
  if not FP4[1].SetZero then Exit;
  Result := True;
end;

function FP4SetOne(FP4: TCnFP4): Boolean;
begin
  Result := False;
  if not FP4[1].SetZero then Exit;
  if not FP4[0].SetOne then Exit;
  Result := True;
end;

function FP4SetU(FP4: TCnFP4): Boolean;
begin
  Result := False;
  if not FP4[1].SetZero then Exit;
  if not FP4[0].SetU then Exit;
  Result := True;
end;

function FP4SetV(FP4: TCnFP4): Boolean;
begin
  Result := False;
  if not FP4[0].SetZero then Exit;
  if not FP4[1].SetOne then Exit;
  Result := True;
end;

function FP4SetBigNumber(const FP4: TCnFP4; const Num: TCnBigNumber): Boolean;
begin
  Result := False;
  if not FP4[1].SetZero then Exit;
  if not FP4[0].SetBigNumber(Num) then Exit;
  Result := True;
end;

function FP4SetBigNumbers(const FP4: TCnFP4; const Num0, Num1: TCnBigNumber): Boolean;
begin
  Result := False;
  if not FP4[0].SetBigNumber(Num0) then Exit;
  if not FP4[1].SetBigNumber(Num1) then Exit;
  Result := True;
end;

function FP4SetFP2(const FP4: TCnFP4; const FP2: TCnFP2): Boolean;
begin
  Result := False;
  if not FP4[1].SetZero then Exit;
  if FP2Copy(FP4[0], FP2) = nil then Exit;
  Result := True;
end;

function FP4Set2FP2S(const FP4: TCnFP4; const FP20, FP21: TCnFP2): Boolean;
begin
  Result := False;
  if FP2Copy(FP4[0], FP20) = nil then Exit;
  if FP2Copy(FP4[1], FP21) = nil then Exit;
  Result := True;
end;

function FP4SetHex(const FP4: TCnFP4; const S0, S1, S2, S3: string): Boolean;
begin
  Result := False;
  if not FP4[1].SetHex(S2, S3) then Exit;
  if not FP4[0].SetHex(S0, S1) then Exit;
  Result := True;
end;

function FP4ToString(const FP4: TCnFP4): string;
begin
  Result := FP4[1].ToString + CRLF + FP4[0].ToString;
end;

function FP4SetWord(const FP4: TCnFP4; Value: Cardinal): Boolean;
begin
  Result := False;
  if not FP4[1].SetZero then Exit;
  if not FP4[0].SetWord(Value) then Exit;
  Result := True;
end;

function FP4SetWords(const FP4: TCnFP4; Value0, Value1, Value2, Value3: Cardinal): Boolean;
begin
  Result := False;
  if not FP4[0].SetWords(Value0, Value1) then Exit;
  if not FP4[1].SetWords(Value2, Value3) then Exit;
  Result := True;
end;

function FP4Equal(const F1, F2: TCnFP4): Boolean;
begin
  Result := FP2Equal(F1[0], F2[0]) and FP2Equal(F1[1], F2[1]);
end;

function FP4Copy(const Dst, Src: TCnFP4): TCnFP4;
begin
  Result := nil;
  if FP2Copy(Dst[0], Src[0]) = nil then Exit;
  if FP2Copy(Dst[1], Src[1]) = nil then Exit;
  Result := Dst;
end;

function FP4Negate(const Res: TCnFP4; const F: TCnFP4; Prime: TCnBigNumber): Boolean;
begin
  Result := FP2Negate(Res[0], F[0], Prime) and FP2Negate(Res[1], F[1], Prime);
end;

function FP4Add(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
begin
  Result := FP2Add(Res[0], F1[0], F2[0], Prime) and FP2Add(Res[1], F1[1], F2[1], Prime);
end;

function FP4Sub(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
begin
  Result := FP2Sub(Res[0], F1[0], F2[0], Prime) and FP2Sub(Res[1], F1[1], F2[1], Prime);
end;

function FP4Mul(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
var
  T, R0, R1: TCnFP2;
begin
  Result := False;

  // r0 = a0 * b0 + a1 * b1 * u
  // r1 = a0 * b1 + a1 * b0
  T := nil;
  R0 := nil;
  R1 := nil;

  try
    T := FLocalFP2Pool.Obtain;
    R0 := FLocalFP2Pool.Obtain;
    R1 := FLocalFP2Pool.Obtain;

    if not FP2Mul(R0, F1[0], F2[0], Prime) then Exit;
    if not FP2MulU(T, F1[1], F2[1], Prime) then Exit;
    if not FP2Add(R0, R0, T, Prime) then Exit;

    if not FP2Mul(R1, F1[0], F2[1], Prime) then Exit;
    if not FP2Mul(T, F1[1], F2[0], Prime) then Exit;
    if not FP2Add(Res[1], R1, T, Prime) then Exit;

    if FP2Copy(Res[0], R0) = nil then Exit;
    Result := True;
  finally
    FLocalFP2Pool.Recycle(R1);
    FLocalFP2Pool.Recycle(R0);
    FLocalFP2Pool.Recycle(T);
  end;
end;

function FP4Mul3(const Res: TCnFP4; const F: TCnFP4; Prime: TCnBigNumber): Boolean;
var
  T: TCnFP4;
begin
  Result := False;
  T := FLocalFP4Pool.Obtain;
  try
    if not FP4Add(T, F, F, Prime) then Exit;
    if not FP4Add(Res, T, F, Prime) then Exit;
    Result := True;
  finally
    FLocalFP4Pool.Recycle(T);
  end;
end;

function FP4MulV(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
var
  T, R0, R1: TCnFP2;
begin
  Result := False;

  // r0 = a0 * b1 * u + a1 * b0 * u
  // r1 = a0 * b0 + a1 * b1 * u
  T := nil;
  R0 := nil;
  R1 := nil;

  try
    T := FLocalFP2Pool.Obtain;
    R0 := FLocalFP2Pool.Obtain;
    R1 := FLocalFP2Pool.Obtain;

    if not FP2MulU(R0, F1[0], F2[1], Prime) then Exit;
    if not FP2MulU(T, F1[1], F2[0], Prime) then Exit;
    if not FP2Add(R0, R0, T, Prime) then Exit;

    if not FP2Mul(R1, F1[0], F2[0], Prime) then Exit;
    if not FP2MulU(T, F1[1], F2[1], Prime) then Exit;
    if not FP2Add(Res[1], R1, T, Prime) then Exit;

    if FP2Copy(Res[0], R0) = nil then Exit;
    Result := True;
  finally
    FLocalFP2Pool.Recycle(R1);
    FLocalFP2Pool.Recycle(R0);
    FLocalFP2Pool.Recycle(T);
  end;
end;

function FP4Inverse(const Res: TCnFP4; const F: TCnFP4; Prime: TCnBigNumber): Boolean;
var
  R0, R1, K: TCnFP2;
begin
  Result := False;

  // k = (f1^2 * u - f0^2)^-1
  // r0 = -(f0 * k)
  // r1 = f1 * k
  K := nil;
  R0 := nil;
  R1 := nil;

  try
    K := FLocalFP2Pool.Obtain;
    R0 := FLocalFP2Pool.Obtain;
    R1 := FLocalFP2Pool.Obtain;

    if not FP2MulU(K, F[1], F[1], Prime) then Exit;
    if not FP2Mul(R0, F[0], F[0], Prime) then Exit;
    if not FP2Sub(K, K, R0, Prime) then Exit;
    if not FP2Inverse(K, K, Prime) then Exit;

    if not FP2Mul(R0, F[0], K, Prime) then Exit;
    if not FP2Negate(R0, R0, Prime) then Exit;

    if not FP2Mul(R1, F[1], K, Prime) then Exit;

    if FP2Copy(Res[0], R0) = nil then Exit;
    if FP2Copy(Res[1], R1) = nil then Exit;
    Result := True;
  finally
    FLocalFP2Pool.Recycle(R1);
    FLocalFP2Pool.Recycle(R0);
    FLocalFP2Pool.Recycle(K);
  end;
end;

function FP4Div(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
var
  Inv: TCnFP4;
begin
  Result := False;
  if F2.IsZero then
    raise EZeroDivide.Create(SDivByZero);

  if F1 = F2 then
  begin
    if not Res.SetOne then Exit;
    Result := True;
  end
  else
  begin
    Inv := FLocalFP4Pool.Obtain;
    try
      if not FP4Inverse(Inv, F2, Prime) then Exit;
      if not FP4Mul(Res, F1, Inv, Prime) then Exit;
    finally
      FLocalFP4Pool.Recycle(Inv);
    end;
  end;
end;

function FP4ToStream(FP4: TCnFP4; Stream: TStream; FixedLen: Integer): Integer;
begin
  Result := FP2ToStream(FP4[1], Stream, FixedLen) + FP2ToStream(FP4[0], Stream, FixedLen);
end;

// ===================== 十二次扩域大整系数元素运算函数 ========================

function FP12New: TCnFP12;
begin
  Result := TCnFP12.Create;
end;

procedure FP12Free(FP12: TCnFP12);
begin
  FP12.Free;
end;

function FP12IsZero(FP12: TCnFP12): Boolean;
begin
  Result := FP12[0].IsZero and FP12[1].IsZero and FP12[2].IsZero;
end;

function FP12IsOne(FP12: TCnFP12): Boolean;
begin
  Result := FP12[0].IsOne and FP12[1].IsZero and FP12[2].IsZero;
end;

function FP12SetZero(FP12: TCnFP12): Boolean;
begin
  Result := False;
  if not FP12[0].SetZero then Exit;
  if not FP12[1].SetZero then Exit;
  if not FP12[2].SetZero then Exit;
  Result := True;
end;

function FP12SetOne(FP12: TCnFP12): Boolean;
begin
  Result := False;
  if not FP12[0].SetOne then Exit;
  if not FP12[1].SetZero then Exit;
  if not FP12[2].SetZero then Exit;
  Result := True;
end;

function FP12SetU(FP12: TCnFP12): Boolean;
begin
  Result := False;
  if not FP12[0].SetU then Exit;
  if not FP12[1].SetZero then Exit;
  if not FP12[2].SetZero then Exit;
  Result := True;
end;

function FP12SetV(FP12: TCnFP12): Boolean;
begin
  Result := False;
  if not FP12[0].SetV then Exit;
  if not FP12[1].SetZero then Exit;
  if not FP12[2].SetZero then Exit;
  Result := True;
end;

function FP12SetW(FP12: TCnFP12): Boolean;
begin
  Result := False;
  if not FP12[0].SetZero then Exit;
  if not FP12[1].SetOne then Exit;
  if not FP12[2].SetZero then Exit;
  Result := True;
end;

function FP12SetWSqr(FP12: TCnFP12): Boolean;
begin
  Result := False;
  if not FP12[0].SetZero then Exit;
  if not FP12[1].SetZero then Exit;
  if not FP12[2].SetOne then Exit;
  Result := True;
end;

function FP12SetBigNumber(const FP12: TCnFP12; const Num: TCnBigNumber): Boolean;
begin
  Result := False;
  if not FP12[0].SetBigNumber(Num) then Exit;
  if not FP12[1].SetZero then Exit;
  if not FP12[2].SetZero then Exit;
  Result := True;
end;

function FP12SetBigNumbers(const FP12: TCnFP12; const Num0, Num1, Num2: TCnBigNumber): Boolean;
begin
  Result := False;
  if not FP12[0].SetBigNumber(Num0) then Exit;
  if not FP12[1].SetBigNumber(Num1) then Exit;
  if not FP12[2].SetBigNumber(Num2) then Exit;
  Result := True;
end;

function FP12SetFP4(const FP12: TCnFP12; const FP4: TCnFP4): Boolean;
begin
  Result := False;
  if FP4Copy(FP12[0], FP4) = nil then Exit;
  if not FP12[1].SetZero then Exit;
  if not FP12[2].SetZero then Exit;
  Result := True;
end;

function FP12Set3FP4S(const FP12: TCnFP12; const FP40, FP41, FP42: TCnFP4): Boolean;
begin
  Result := False;
  if FP4Copy(FP12[0], FP40) = nil then Exit;
  if FP4Copy(FP12[1], FP41) = nil then Exit;
  if FP4Copy(FP12[2], FP42) = nil then Exit;
  Result := True;
end;

function FP12SetFP2(const FP12: TCnFP12; const FP2: TCnFP2): Boolean;
begin
  Result := False;
  if not FP4SetFP2(FP12[0], FP2) then Exit;
  if not FP12[1].SetZero then Exit;
  if not FP12[2].SetZero then Exit;
  Result := True;
end;

function FP12SetHex(const FP12: TCnFP12; const S0, S1, S2, S3, S4, S5, S6, S7, S8,
  S9, S10, S11: string): Boolean;
begin
  Result := False;
  if not FP12[0].SetHex(S0, S1, S2, S3) then Exit;
  if not FP12[1].SetHex(S4, S5, S6, S7) then Exit;
  if not FP12[2].SetHex(S8, S9, S10, S11) then Exit;
  Result := True;
end;

function FP12ToString(const FP12: TCnFP12): string;
begin
  Result := FP12[2].ToString + CRLF + FP12[1].ToString + CRLF + FP12[0].ToString;
end;

function FP12SetWord(const FP12: TCnFP12; Value: Cardinal): Boolean;
begin
  Result := False;
  if not FP4SetWord(FP12[0], Value) then Exit;
  if not FP12[1].SetZero then Exit;
  if not FP12[2].SetZero then Exit;
  Result := True;
end;

function FP12SetWords(const FP12: TCnFP12; Value0, Value1, Value2, Value3, Value4,
  Value5, Value6, Value7, Value8, Value9, Value10, Value11: Cardinal): Boolean;
begin
  Result := False;
  if not FP12[0].SetWords(Value0, Value1, Value2, Value3) then Exit;
  if not FP12[1].SetWords(Value4, Value5, Value6, Value7) then Exit;
  if not FP12[2].SetWords(Value8, Value9, Value10, Value11) then Exit;
  Result := True;
end;

function FP12Equal(const F1, F2: TCnFP12): Boolean;
begin
  Result := FP4Equal(F1[0], F2[0]) and FP4Equal(F1[1], F2[1]) and FP4Equal(F1[2], F2[2]);
end;

function FP12Copy(const Dst, Src: TCnFP12): TCnFP12;
begin
  Result := nil;
  if FP4Copy(Dst[0], Src[0]) = nil then Exit;
  if FP4Copy(Dst[1], Src[1]) = nil then Exit;
  if FP4Copy(Dst[2], Src[2]) = nil then Exit;
  Result := Dst;
end;

function FP12Negate(const Res: TCnFP12; const F: TCnFP12; Prime: TCnBigNumber): Boolean;
begin
  Result := False;
  if not FP4Negate(Res[0], F[0], Prime) then Exit;
  if not FP4Negate(Res[1], F[1], Prime) then Exit;
  if not FP4Negate(Res[2], F[2], Prime) then Exit;
  Result := True;
end;

function FP12Add(const Res: TCnFP12; const F1, F2: TCnFP12; Prime: TCnBigNumber): Boolean;
begin
  Result := False;
  if not FP4Add(Res[0], F1[0], F2[0], Prime) then Exit;
  if not FP4Add(Res[1], F1[1], F2[1], Prime) then Exit;
  if not FP4Add(Res[2], F1[2], F2[2], Prime) then Exit;
  Result := True;
end;

function FP12Sub(const Res: TCnFP12; const F1, F2: TCnFP12; Prime: TCnBigNumber): Boolean;
begin
  Result := False;
  if not FP4Sub(Res[0], F1[0], F2[0], Prime) then Exit;
  if not FP4Sub(Res[1], F1[1], F2[1], Prime) then Exit;
  if not FP4Sub(Res[2], F1[2], F2[2], Prime) then Exit;
  Result := True;
end;

function FP12Mul(const Res: TCnFP12; const F1, F2: TCnFP12; Prime: TCnBigNumber): Boolean;
var
  T, R0, R1, R2: TCnFP4;
begin
  Result := False;

  // r0 = a0 * b0 + a1 * b2 * v + a2 * b1 * v
  // r1 = a0 * b1 + a1 * b0 + a2 * b2 *v
  // r2 = a0 * b2 + a1 * b1 + a2 * b0
  T := nil;
  R0 := nil;
  R1 := nil;
  R2 := nil;

  try
    T := FLocalFP4Pool.Obtain;
    R0 := FLocalFP4Pool.Obtain;
    R1 := FLocalFP4Pool.Obtain;
    R2 := FLocalFP4Pool.Obtain;

    if not FP4Mul(R0, F1[0], F2[0], Prime) then Exit;
    if not FP4MulV(T, F1[1], F2[2], Prime) then Exit;
    if not FP4Add(R0, R0, T, Prime) then Exit;
    if not FP4MulV(T, F1[2], F2[1], Prime) then Exit;
    if not FP4Add(R0, R0, T, Prime) then Exit;

    if not FP4Mul(R1, F1[0], F2[1], Prime) then Exit;
    if not FP4Mul(T, F1[1], F2[0], Prime) then Exit;
    if not FP4Add(R1, R1, T, Prime) then Exit;
    if not FP4MulV(T, F1[2], F2[2], Prime) then Exit;
    if not FP4Add(R1, R1, T, Prime) then Exit;

    if not FP4Mul(R2, F1[0], F2[2], Prime) then Exit;
    if not FP4Mul(T, F1[1], F2[1], Prime) then Exit;
    if not FP4Add(R2, R2, T, Prime) then Exit;
    if not FP4Mul(T, F1[2], F2[0], Prime) then Exit;
    if not FP4Add(R2, R2, T, Prime) then Exit;

    if FP4Copy(Res[0], R0) = nil then Exit;
    if FP4Copy(Res[1], R1) = nil then Exit;
    if FP4Copy(Res[2], R2) = nil then Exit;

    Result := True;
  finally
    FLocalFP4Pool.Recycle(R2);
    FLocalFP4Pool.Recycle(R1);
    FLocalFP4Pool.Recycle(R0);
    FLocalFP4Pool.Recycle(T);
  end;
end;

function FP12Mul3(const Res: TCnFP12; const F: TCnFP12; Prime: TCnBigNumber): Boolean;
var
  T: TCnFP12;
begin
  Result := False;
  T := FLocalFP12Pool.Obtain;
  try
    if not FP12Add(T, F, F, Prime) then Exit;
    if not FP12Add(Res, T, F, Prime) then Exit;
    Result := True;
  finally
    FLocalFP12Pool.Recycle(T);
  end;
end;

function FP12Inverse(const Res: TCnFP12; const F: TCnFP12; Prime: TCnBigNumber): Boolean;
var
  K, T, T0, T1, T2, T3: TCnFP4;
begin
  Result := False;

  if FP4IsZero(F[2]) then // 分开处理
  begin
    // k = (f0^3 + f1^3 * v)^-1
    // r2 = f1^2 * k
    // r1 = -(f0 * f1 * k)
    // r0 = f0^2 * k
    K := nil;
    T := nil;

    try
      K := FLocalFP4Pool.Obtain;
      T := FLocalFP4Pool.Obtain;

      if not FP4Mul(K, F[0], F[0], Prime) then Exit;
      if not FP4Mul(K, K, F[0], Prime) then Exit;
      if not FP4MulV(T, F[1], F[1], Prime) then Exit;
      if not FP4Mul(T, T, F[1], Prime) then Exit;
      if not FP4Add(K, K, T, Prime) then Exit;
      if not FP4Inverse(K, K, Prime) then Exit;

      if not FP4Mul(T, F[1], F[1], Prime) then Exit;
      if not FP4Mul(Res[2], T, K, Prime) then Exit;

      if not FP4Mul(T, F[0], F[1], Prime) then Exit;
      if not FP4Mul(T, T, K, Prime) then Exit;
      if not FP4Negate(Res[1], T, Prime) then Exit;

      if not FP4Mul(T, F[0], F[0], Prime) then Exit;
      if not FP4Mul(Res[0], T, K, Prime) then Exit;

      Result := True;
    finally
      FLocalFP4Pool.Recycle(T);
      FLocalFP4Pool.Recycle(K);
    end;
  end
  else
  begin
    T := nil;
    T0 := nil;
    T1 := nil;
    T2 := nil;
    T3 := nil;

    try
      T := FLocalFP4Pool.Obtain;
      T0 := FLocalFP4Pool.Obtain;
      T1 := FLocalFP4Pool.Obtain;
      T2 := FLocalFP4Pool.Obtain;
      T3 := FLocalFP4Pool.Obtain;

      // t0 = f1^2 - f0 * f2
      // t1 = f0 * f1 - f2^2 * v
      // t2 = f0^2 - f1 * f2 * v
      // t3 = f2 * (t1^2 - t0 * t2)^-1
      if not FP4Mul(T0, F[1], F[1], Prime) then Exit;
      if not FP4Mul(T1, F[0], F[2], Prime) then Exit;
      if not FP4Sub(T0, T0, T1, Prime) then Exit;

      if not FP4Mul(T1, F[0], F[1], Prime) then Exit;
      if not FP4MulV(T2, F[2], F[2], Prime) then Exit;
      if not FP4Sub(T1, T1, T2, Prime) then Exit;

      if not FP4Mul(T2, F[0], F[0], Prime) then Exit;
      if not FP4MulV(T3, F[1], F[2], Prime) then Exit;
      if not FP4Sub(T2, T2, T3, Prime) then Exit;

      if not FP4Mul(T3, T1, T1, Prime) then Exit;
      if not FP4Mul(T, T0, T2, Prime) then Exit;
      if not FP4Sub(T3, T3, T, Prime) then Exit;
      if not FP4Inverse(T3, T3, Prime) then Exit;
      if not FP4Mul(T3, F[2], T3, Prime) then Exit;

      // r0 = t2 * t3
      // r1 = -(t1 * t3)
      // r2 = t0 * t3
      if not FP4Mul(Res[0], T2, T3, Prime) then Exit;

      if not FP4Mul(Res[1], T1, T3, Prime) then Exit;
      if not FP4Negate(Res[1], Res[1], Prime) then Exit;

      if not FP4Mul(Res[2], T0, T3, Prime) then Exit;

      Result := True;
    finally
      FLocalFP4Pool.Recycle(T3);
      FLocalFP4Pool.Recycle(T2);
      FLocalFP4Pool.Recycle(T1);
      FLocalFP4Pool.Recycle(T0);
      FLocalFP4Pool.Recycle(T);
    end;
  end;
end;

function FP12Div(const Res: TCnFP12; const F1, F2: TCnFP12; Prime: TCnBigNumber): Boolean;
var
  Inv: TCnFP12;
begin
  Result := False;
  if F2.IsZero then
    raise EZeroDivide.Create(SDivByZero);

  if F1 = F2 then
  begin
    if not Res.SetOne then Exit;
    Result := True;
  end
  else
  begin
    Inv := FLocalFP12Pool.Obtain;
    try
      if not FP12Inverse(Inv, F2, Prime) then Exit;
      if not FP12Mul(Res, F1, Inv, Prime) then Exit;
    finally
      FLocalFP12Pool.Recycle(Inv);
    end;
  end;
end;

function FP12Power(const Res: TCnFP12; const F: TCnFP12; Exponent: TCnBigNumber;
  Prime: TCnBigNumber): Boolean;
var
  I, N: Integer;
  T: TCnFP12;
begin
  Result := False;
  if Exponent.IsZero then
  begin
    if not Res.SetOne then Exit;
    Result := True;
    Exit;
  end
  else if Exponent.IsOne then
  begin
    if FP12Copy(Res, F) = nil then Exit;
    Result := True;
    Exit;
  end;

  N := Exponent.GetBitsCount;
  if Res = F then
    T := FLocalFP12Pool.Obtain
  else
    T := Res;

  if FP12Copy(T, F) = nil then Exit;

  try
    for I := N - 2 downto 0 do  // 指数粗略拿 6 和 13 验证过似乎是对的
    begin
      if not FP12Mul(T, T, T, Prime) then Exit;
      if Exponent.IsBitSet(I) then
        if not FP12Mul(T, T, F, Prime) then Exit;
    end;

    if Res = F then
      if FP12Copy(Res, T) = nil then Exit;
    Result := True;
  finally
    if Res = F then
      FLocalFP12Pool.Recycle(T);
  end;
end;

function FP12ToStream(FP12: TCnFP12; Stream: TStream; FixedLen: Integer): Integer;
begin
  Result := FP4ToStream(FP12[2], Stream, FixedLen) + FP4ToStream(FP12[1], Stream, FixedLen)
    + FP4ToStream(FP12[0], Stream, FixedLen);
end;

// ===================== 仿射坐标系里的三元点的运算函数 ========================

function FP2AffinePointNew: TCnFP2AffinePoint;
begin
  Result := TCnFP2AffinePoint.Create;
end;

procedure AffinePointFree(P: TCnFP2AffinePoint);
begin
  P.Free;
end;

function FP2AffinePointSetZero(P: TCnFP2AffinePoint): Boolean;
begin
  Result := False;
  if not P.X.SetZero then Exit;
  if not P.Y.SetZero then Exit;
  if not P.Z.SetZero then Exit;
  Result := True;
end;

function FP2AffinePointToString(const P: TCnFP2AffinePoint): string;
begin
  Result := 'X: ' + P.X.ToString + CRLF + 'Y: ' + P.Y.ToString + CRLF + 'Z: ' + P.Z.ToString;
end;

function FP2AffinePointEqual(const P1, P2: TCnFP2AffinePoint): Boolean;
begin
  Result := FP2Equal(P1.X, P2.X) and FP2Equal(P1.Y, P2.Y) and FP2Equal(P1.Z, P2.Z);
end;

function FP2AffinePointCopy(const Dst, Src: TCnFP2AffinePoint): TCnFP2AffinePoint;
begin
  Result := nil;
  if FP2Copy(Dst.X, Src.X) = nil then Exit;
  if FP2Copy(Dst.Y, Src.Y) = nil then Exit;
  if FP2Copy(Dst.Z, Src.Z) = nil then Exit;
  Result := Dst;
end;

function FP2AffinePointIsAtInfinity(const P: TCnFP2AffinePoint): Boolean;
begin
  Result := FP2IsZero(P.X) and FP2IsOne(P.Y) and FP2IsZero(P.Z);
end;

function FP2AffinePointSetToInfinity(const P: TCnFP2AffinePoint): Boolean;
begin
  Result := False;
  if not P.X.SetZero then Exit;
  if not P.Y.SetOne then Exit;
  if not P.Z.SetZero then Exit;
  Result := True;
end;

function FP2AffinePointGetCoordinates(const P: TCnFP2AffinePoint; const FP2X, FP2Y: TCnFP2): Boolean;
begin
  Result := False;
  if P.Z.IsOne then
  begin
    if FP2Copy(FP2X, P.X) = nil then Exit;
    if FP2Copy(FP2Y, P.Y) = nil then Exit;
    Result := True;
  end;
end;

function FP2AffinePointSetCoordinates(const P: TCnFP2AffinePoint; const FP2X, FP2Y: TCnFP2): Boolean;
begin
  Result := False;
  if FP2Copy(P.X, FP2X) = nil then Exit;
  if FP2Copy(P.Y, FP2Y) = nil then Exit;
  if not FP2SetOne(P.Z) then Exit;
  Result := True;
end;

function FP2AffinePointSetCoordinatesHex(const P: TCnFP2AffinePoint;
  const SX0, SX1, SY0, SY1: string): Boolean;
begin
  Result := False;
  if not FP2SetHex(P.X, SX0, SX1) then Exit;
  if not FP2SetHex(P.Y, SY0, SY1) then Exit;
  if not FP2SetOne(P.Z) then Exit;
  Result := True;
end;

function FP2AffinePointSetCoordinatesBigNumbers(const P: TCnFP2AffinePoint;
  const X0, X1, Y0, Y1: TCnBigNumber): Boolean;
begin
  Result := False;
  if not FP2SetBigNumbers(P.X, X0, X1) then Exit;
  if not FP2SetBigNumbers(P.Y, X1, Y1) then Exit;
  if not FP2SetOne(P.Z) then Exit;
  Result := True;
end;

function FP2AffinePointGetJacobianCoordinates(const P: TCnFP2AffinePoint;
  const FP12X, FP12Y: TCnFP12; Prime: TCnBigNumber): Boolean;
var
  X, Y: TCnFP2;
  W: TCnFP12;
begin
  Result := False;

  X := nil;
  Y := nil;
  W := nil;

  try
    X := FLocalFP2Pool.Obtain;
    Y := FLocalFP2Pool.Obtain;
    W := FLocalFP12Pool.Obtain;

    if not FP2AffinePointGetCoordinates(P, X, Y) then Exit;
    if not FP12SetFP2(FP12X, X) then Exit;
    if not FP12SetFP2(FP12Y, Y) then Exit;

    // x = x * w^-2
    if not FP12SetWSqr(W) then Exit;
    if not FP12Inverse(W, W, Prime) then Exit;
    if not FP12Mul(FP12X, FP12X, W, Prime) then Exit;

    // y = y * w^-3
    if not FP12SetV(W) then Exit;
    if not FP12Inverse(W, W, Prime) then Exit;
    if not FP12Mul(FP12Y, FP12Y, W, Prime) then Exit;

    Result := True;
  finally
    FLocalFP2Pool.Recycle(Y);
    FLocalFP2Pool.Recycle(X);
    FLocalFP12Pool.Recycle(W);
  end;
end;

function FP2AffinePointSetJacobianCoordinates(const P: TCnFP2AffinePoint;
  const FP12X, FP12Y: TCnFP12; Prime: TCnBigNumber): Boolean;
var
  TX, TY: TCnFP12;
begin
  Result := False;

  TX := nil;
  TY := nil;

  try
    TX := FLocalFP12Pool.Obtain;
    TY := FLocalFP12Pool.Obtain;

    if not FP12SetWSqr(TX) then Exit;
    if not FP12SetV(TY) then Exit;
    if not FP12Mul(TX, FP12X, TX, Prime) then Exit;
    if not FP12Mul(TY, FP12Y, TY, Prime) then Exit;

    if not FP2AffinePointSetCoordinates(P, TX[0][0], TY[0][0]) then Exit;
    Result := True;
  finally
    FLocalFP12Pool.Recycle(TY);
    FLocalFP12Pool.Recycle(TX);
  end;
end;

function FP2AffinePointIsOnCurve(const P: TCnFP2AffinePoint; Prime: TCnBigNumber): Boolean;
var
  X, Y, B, T: TCnFP2;
begin
  Result := False;

  X := nil;
  Y := nil;
  B := nil;
  T := nil;

  try
    X := FLocalFP2Pool.Obtain;
    Y := FLocalFP2Pool.Obtain;
    B := FLocalFP2Pool.Obtain;
    T := FLocalFP2Pool.Obtain;

    if not B[0].SetZero then Exit;
    if not B[1].SetWord(CN_SM9_ECC_B) then Exit;   // B 给 5

    if not FP2AffinePointGetCoordinates(P, X, Y) then Exit;

    // X^3 + 5 u
    if not FP2Mul(T, X, X, Prime) then Exit;
    if not FP2Mul(X, X, T, Prime) then Exit;
    if not FP2Add(X, X, B, Prime) then Exit;

    // Y^2
    if not FP2Mul(Y, Y, Y, Prime) then Exit;

    Result := FP2Equal(X, Y);
  finally
    FLocalFP2Pool.Recycle(T);
    FLocalFP2Pool.Recycle(B);
    FLocalFP2Pool.Recycle(Y);
    FLocalFP2Pool.Recycle(X);
  end;
end;

function FP2AffinePointNegate(const Res: TCnFP2AffinePoint; const P: TCnFP2AffinePoint;
  Prime: TCnBigNumber): Boolean;
begin
  Result := False;
  if FP2Copy(Res.X, P.X) = nil then Exit;
  if not FP2Negate(Res.Y, P.Y, Prime) then Exit;
  if FP2Copy(Res.Z, P.Z) = nil then Exit;
  Result := True; 
end;

function FP2AffinePointDouble(const Res: TCnFP2AffinePoint; const P: TCnFP2AffinePoint;
  Prime: TCnBigNumber): Boolean;
var
  L, T, X1, Y1, X2, Y2: TCnFP2;
begin
  Result := False;
  if P.IsAtInfinity then
  begin
    Result := Res.SetToInfinity;
    Exit;
  end;

  L := nil;
  T := nil;
  X1 := nil;
  Y1 := nil;
  X2 := nil;
  Y2 := nil;

  try
    L := FLocalFP2Pool.Obtain;
    T := FLocalFP2Pool.Obtain;
    X1 := FLocalFP2Pool.Obtain;
    Y1 := FLocalFP2Pool.Obtain;
    X2 := FLocalFP2Pool.Obtain;
    Y2 := FLocalFP2Pool.Obtain;

    if not FP2AffinePointGetCoordinates(P, X1, Y1) then Exit;

    // L := 3 * x1^2 / (2 * y1)
    if not FP2Mul(L, X1, X1, Prime) then Exit;
    if not FP2Mul3(L, L, Prime) then Exit;
    if not FP2Add(T, Y1, Y1, Prime) then Exit;
    if not FP2Inverse(T, T, Prime) then Exit;
    if not FP2Mul(L, L, T, Prime) then Exit;

    // X2 = L^2 - 2 * X1
    if not FP2Mul(X2, L, L, Prime) then Exit;
    if not FP2Add(T, X1, X1, Prime) then Exit;
    if not FP2Sub(X2, X2, T, Prime) then Exit;

    // Y2 = L * (X1 - X2) - Y1
    if not FP2Sub(Y2, X1, X2, Prime) then Exit;
    if not FP2Mul(Y2, L, Y2, Prime) then Exit;
    if not FP2Sub(Y2, Y2, Y1, Prime) then Exit;

    if not FP2AffinePointSetCoordinates(Res, X2, Y2) then Exit;

    Result := True;
  finally
    FLocalFP2Pool.Recycle(Y2);
    FLocalFP2Pool.Recycle(X2);
    FLocalFP2Pool.Recycle(Y1);
    FLocalFP2Pool.Recycle(X1);
    FLocalFP2Pool.Recycle(T);
    FLocalFP2Pool.Recycle(L);
  end;
end;

function FP2AffinePointAdd(const Res: TCnFP2AffinePoint; const P, Q: TCnFP2AffinePoint;
  Prime: TCnBigNumber): Boolean;
var
  X1, Y1, X2, Y2, X3, Y3, L, T: TCnFP2;
begin
  Result := False;

  if FP2AffinePointIsAtInfinity(P) then
    Result := FP2AffinePointCopy(Res, Q) <> nil
  else if FP2AffinePointIsAtInfinity(Q) then
    Result := FP2AffinePointCopy(Res, P) <> nil
  else if FP2AffinePointEqual(P, Q) then
    Result := FP2AffinePointDouble(P, Q, Prime)
  else
  begin
    T := nil;
    L := nil;
    X1 := nil;
    Y1 := nil;
    X2 := nil;
    Y2 := nil;
    X3 := nil;
    Y3 := nil;

    try
      T := FLocalFP2Pool.Obtain;
      L := FLocalFP2Pool.Obtain;
      X1 := FLocalFP2Pool.Obtain;
      Y1 := FLocalFP2Pool.Obtain;
      X2 := FLocalFP2Pool.Obtain;
      Y2 := FLocalFP2Pool.Obtain;
      X3 := FLocalFP2Pool.Obtain;
      Y3 := FLocalFP2Pool.Obtain;

      if not FP2AffinePointGetCoordinates(P, X1, Y1) then Exit;
      if not FP2AffinePointGetCoordinates(Q, X2, Y2) then Exit;
      if not FP2Add(T, Y1, Y2, Prime) then Exit;

      if T.IsZero and FP2Equal(X1, X2) then // 正负点
      begin
        Result := Res.SetToInfinity; // 和为 0
        Exit;
      end;

      // L = (Y2 - Y1)/(X2 - X1)
      if not FP2Sub(L, Y2, Y1, Prime) then Exit;
      if not FP2Sub(T, X2, X1, Prime) then Exit;
      if not FP2Inverse(T, T, Prime) then Exit;
      if not FP2Mul(L, L, T, Prime) then Exit;

      // X3 = L^2 - X1 - X2
      if not FP2Mul(X3, L, L, Prime) then Exit;
      if not FP2Sub(X3, X3, X1, Prime) then Exit;
      if not FP2Sub(X3, X3, X2, Prime) then Exit;

      // Y3 = L * (X1 - X3) - Y1
      if not FP2Sub(Y3, X1, X3, Prime) then Exit;
      if not FP2Mul(Y3, L, Y3, Prime) then Exit;
      if not FP2Sub(Y3, Y3, Y1, Prime) then Exit;

      Result := FP2AffinePointSetCoordinates(Res, X3, Y3);
    finally
      FLocalFP2Pool.Recycle(Y3);
      FLocalFP2Pool.Recycle(X3);
      FLocalFP2Pool.Recycle(Y2);
      FLocalFP2Pool.Recycle(X2);
      FLocalFP2Pool.Recycle(Y1);
      FLocalFP2Pool.Recycle(X1);
      FLocalFP2Pool.Recycle(L);
      FLocalFP2Pool.Recycle(T);
    end;
  end;
end;

function FP2AffinePointSub(const Res: TCnFP2AffinePoint; const P, Q: TCnFP2AffinePoint;
  Prime: TCnBigNumber): Boolean;
var
  T: TCnFP2AffinePoint;
begin
  Result := False;
  T := FLocalFP2AffinePointPool.Obtain;
  try
    if not FP2AffinePointNegate(T, Q, Prime) then Exit;
    if not FP2AffinePointAdd(Res, P, T, Prime) then Exit;
    Result := True;
  finally
    FLocalFP2AffinePointPool.Recycle(T);
  end;
end;

function FP2AffinePointMul(const Res: TCnFP2AffinePoint; const P: TCnFP2AffinePoint;
  Num: TCnBigNumber; Prime: TCnBigNumber): Boolean;
var
  I, N: Integer;
  T: TCnFP2AffinePoint;
begin
  Result := False;

  if Num.IsZero then
    Result := FP2AffinePointSetToInfinity(Res)
  else if Num.IsOne then
    Result := FP2AffinePointCopy(Res, P) <> nil
  else  // 乘对于加，等同于幂对于乘，所以和 Power 算法类似
  begin
    N := Num.GetBitsCount;
    if Res = P then
      T := FLocalFP2AffinePointPool.Obtain
    else
      T := Res;
        
    try
      FP2AffinePointCopy(T, P);
      for I := N - 2 downto 0 do
      begin
        if not FP2AffinePointDouble(T, T, Prime) then Exit;
        if Num.IsBitSet(I) then
          if not FP2AffinePointAdd(T, T, P, Prime) then Exit;
      end;

      if Res = P then
        if FP2AffinePointCopy(Res, T) = nil then Exit;
      Result := True;
    finally
      if Res = P then
        FLocalFP2AffinePointPool.Recycle(T);
    end;
  end;
end;

function FP2AffinePointFrobenius(const Res: TCnFP2AffinePoint; const P: TCnFP2AffinePoint;
  Prime: TCnBigNumber): Boolean;
var
  X, Y: TCnFP12;
begin
  Result := False;

  X := nil;
  Y := nil;

  try
    X := FLocalFP12Pool.Obtain;
    Y := FLocalFP12Pool.Obtain;

    if not FP2AffinePointGetJacobianCoordinates(P, X, Y, Prime) then Exit;
    if not FP12Power(X, X, Prime, Prime) then Exit;
    if not FP12Power(Y, Y, Prime, Prime) then Exit;
    if not FP2AffinePointSetJacobianCoordinates(Res, X, Y, Prime) then Exit;
    Result := True;
  finally
    FLocalFP12Pool.Recycle(Y);
    FLocalFP12Pool.Recycle(X);
  end;
end;

function FP2PointToString(const P: TCnFP2Point): string;
begin
  Result := 'X: ' + P.X.ToString + CRLF + 'Y: ' + P.Y.ToString;
end;

function FP2AffinePointToFP2Point(FP2P: TCnFP2Point; FP2AP: TCnFP2AffinePoint;
  Prime: TCnBigNumber): Boolean;
var
  V: TCnFP2;
begin
  // X := X/Z   Y := Y/Z
  Result := False;

  V := FLocalFP2Pool.Obtain;
  try
    if not FP2Inverse(V, FP2AP.Z, Prime) then Exit;
    if not FP2Mul(FP2P.X, FP2AP.X, V, Prime) then Exit;
    if not FP2Mul(FP2P.Y, FP2AP.Y, V, Prime) then Exit;
  finally
    FLocalFP2Pool.Recycle(V);
  end;
end;

function FP2PointToFP2AffinePoint(FP2AP: TCnFP2AffinePoint; FP2P: TCnFP2Point): Boolean;
begin
  Result := False;
  if FP2Copy(FP2AP.X, FP2P.X) = nil then Exit;
  if FP2Copy(FP2AP.Y, FP2P.Y) = nil then Exit;

  if FP2AP.X.IsZero and FP2AP.Y.IsZero then
    Result := FP2AP.Z.SetZero
  else
    Result := FP2AP.Z.SetOne;
end;

// ============================ 双线性对计算函数 ===============================

// 求一点切线
function Tangent(const Res: TCnFP12; const T: TCnFP2AffinePoint;
  const XP, YP: TCnBigNumber; Prime: TCnBigNumber): Boolean;
var
  X, Y, XT, YT, L, Q: TCnFP12;
begin
  Result := False;

  X := nil;
  Y := nil;
  XT := nil;
  YT := nil;
  L := nil;
  Q := nil;

  try
    X := FLocalFP12Pool.Obtain;
    Y := FLocalFP12Pool.Obtain;
    XT := FLocalFP12Pool.Obtain;
    YT := FLocalFP12Pool.Obtain;
    L := FLocalFP12Pool.Obtain;
    Q := FLocalFP12Pool.Obtain;

    if not FP2AffinePointGetJacobianCoordinates(T, XT, YT, Prime) then Exit;

    if not FP12SetBigNumber(X, XP) then Exit;
    if not FP12SetBigNumber(Y, YP) then Exit;

    // L = (3 * YT^2)/(2 * YT)
    if not FP12Mul(L, XT, XT, Prime) then Exit;
    if not FP12Mul3(L, L, Prime) then Exit;
    if not FP12Add(Q, YT, YT, Prime) then Exit;
    if not FP12Inverse(Q, Q, Prime) then Exit;
    if not FP12Mul(L, L, Q, Prime) then Exit;

    // r = lambda * (x - xT) - y + yT
    if not FP12Sub(Res, X, XT, Prime) then Exit;
    if not FP12Mul(Res, L, Res, Prime) then Exit;
    if not FP12Sub(Res, Res, Y, Prime) then Exit;
    if not FP12Add(Res, Res, YT, Prime) then Exit;

    Result := True;
  finally
    FLocalFP12Pool.Recycle(Q);
    FLocalFP12Pool.Recycle(L);
    FLocalFP12Pool.Recycle(YT);
    FLocalFP12Pool.Recycle(XT);
    FLocalFP12Pool.Recycle(Y);
    FLocalFP12Pool.Recycle(X);
  end;
end;

// 求两点割线
function Secant(const Res: TCnFP12; const T, Q: TCnFP2AffinePoint;
  const XP, YP: TCnBigNumber; Prime: TCnBigNumber): Boolean;
var
  X, Y, L, M, XT, YT, XQ, YQ: TCnFP12;
begin
  Result := False;

  X := nil;
  Y := nil;
  L := nil;
  M := nil;
  XT := nil;
  YT := nil;
  XQ := nil;
  YQ := nil;

  try
    X := FLocalFP12Pool.Obtain;
    Y := FLocalFP12Pool.Obtain;
    L := FLocalFP12Pool.Obtain;
    M := FLocalFP12Pool.Obtain;
    XT := FLocalFP12Pool.Obtain;
    YT := FLocalFP12Pool.Obtain;
    XQ := FLocalFP12Pool.Obtain;
    YQ := FLocalFP12Pool.Obtain;

    if not FP2AffinePointGetJacobianCoordinates(T, XT, YT, Prime) then Exit;
    if not FP2AffinePointGetJacobianCoordinates(Q, XQ, YQ, Prime) then Exit;

    if not FP12SetBigNumber(X, XP) then Exit;
    if not FP12SetBigNumber(Y, YP) then Exit;

    // L = (yT - yQ)/(xT - xQ)
    if not FP12Sub(L, YT, YQ, Prime) then Exit;
    if not FP12Sub(M, XT, XQ, Prime) then Exit;
    if not FP12Inverse(M, M, Prime) then Exit;
    if not FP12Mul(L, L, M, Prime) then Exit;

    // r = L * (x - xQ) - y + yQ
    if not FP12Sub(Res, X, XQ, Prime) then Exit;
    if not FP12Mul(Res, L, Res, Prime) then Exit;
    if not FP12Sub(Res, Res, Y, Prime) then Exit;
    if not FP12Add(Res, Res, YQ, Prime) then Exit;

    Result := True;
  finally
    FLocalFP12Pool.Recycle(YQ);
    FLocalFP12Pool.Recycle(XQ);
    FLocalFP12Pool.Recycle(YT);
    FLocalFP12Pool.Recycle(XT);
    FLocalFP12Pool.Recycle(M);
    FLocalFP12Pool.Recycle(L);
    FLocalFP12Pool.Recycle(Y);
    FLocalFP12Pool.Recycle(X);
  end;
end;

function FP12FastExp1(const Res: TCnFP12; const F: TCnFP12; Prime: TCnBigNumber): Boolean;
begin
  Result := False;
  if FP2Copy(Res[0][0], F[0][0]) = nil then Exit;
  if not FP2Negate(Res[0][1], F[0][1], Prime) then Exit;
  if not FP2Negate(Res[1][0], F[1][0], Prime) then Exit;
  if FP2Copy(Res[1][1], F[1][1]) = nil then Exit;
  if FP2Copy(Res[2][0], F[2][0]) = nil then Exit;
  if not FP2Negate(Res[2][1], F[2][1], Prime) then Exit;
  Result := True;
end;

function FP12FastExp2(const Res: TCnFP12; const F: TCnFP12; Prime: TCnBigNumber): Boolean;
begin
  Result := False;
  if FP2Copy(Res[0][0], F[0][0]) = nil then Exit;
  if not FP2Negate(Res[0][1], F[0][1], Prime) then Exit;
  if not FP2Mul(Res[1][0], F[1][0], FFP12FastExpPW20, Prime) then Exit;
  if not FP2Mul(Res[1][1], F[1][1], FFP12FastExpPW21, Prime) then Exit;
  if not FP2Mul(Res[2][0], F[2][0], FFP12FastExpPW22, Prime) then Exit;
  if not FP2Mul(Res[2][1], F[2][1], FFP12FastExpPW23, Prime) then Exit;
  Result := True;
end;

function FinalFastExp(const Res: TCnFP12; const F: TCnFP12; const K: TCnBigNumber;
  Prime: TCnBigNumber): Boolean;
var
  I, N: Integer;
  T, T0: TCnFP12;
begin
  Result := False;

  T := nil;
  T0 := nil;

  try
    T := FLocalFP12Pool.Obtain;
    T0 := FLocalFP12Pool.Obtain;

    if FP12Copy(T, F) = nil then Exit;
    // FP12Copy(T0, F);
    if not FP12Inverse(T0, T, Prime) then Exit;
    if not FP12FastExp1(T, T, Prime) then Exit;
    if not FP12Mul(T, T0, T, Prime) then Exit;
    if FP12Copy(T0, T) = nil then Exit;

    if not FP12FastExp2(T, T, Prime) then Exit;
    if not FP12Mul(T, T0, T, Prime) then Exit;
    if FP12Copy(T0, T) = nil then Exit;

    N := K.GetBitsCount;
    for I := N - 2 downto 0 do
    begin
      if not FP12Mul(T, T, T, Prime) then Exit;
      if K.IsBitSet(I) then
        if not FP12Mul(T, T, T0, Prime) then Exit;
    end;

    if FP12Copy(Res, T) = nil then Exit;
    Result := True;
  finally
    FLocalFP12Pool.Recycle(T0);
    FLocalFP12Pool.Recycle(T);
  end;
end;

function Rate(const F: TCnFP12; const Q: TCnFP2AffinePoint; const XP, YP: TCnBigNumber;
  const A: TCnBigNumber; const K: TCnBigNumber; Prime: TCnBigNumber): Boolean;
var
  I, N: Integer;
  T, Q1, Q2: TCnFP2AffinePoint;
  G: TCnFP12;
begin
  Result := False;

  T := nil;
  Q1 := nil;
  Q2 := nil;
  G := nil;

  try
    T := FLocalFP2AffinePointPool.Obtain;
    Q1 := FLocalFP2AffinePointPool.Obtain;
    Q2 := FLocalFP2AffinePointPool.Obtain;
    G := FLocalFP12Pool.Obtain;

    if not FP12SetOne(F) then Exit;
    if FP2AffinePointCopy(T, Q) = nil then Exit;
    N := A.GetBitsCount;

    for I := N - 2 downto 0 do
    begin
      if not Tangent(G, T, XP, YP, Prime) then Exit;
      if not FP12Mul(F, F, F, Prime) then Exit;
      if not FP12Mul(F, F, G, Prime) then Exit;

      if not FP2AffinePointDouble(T, T, Prime) then Exit;

      if A.IsBitSet(I) then
      begin
        if not Secant(G, T, Q, XP, YP, Prime) then Exit;
        if not FP12Mul(F, F, G, Prime) then Exit;
        if not FP2AffinePointAdd(T, T, Q, Prime) then Exit;
      end;
    end;

    if not FP2AffinePointFrobenius(Q1, Q, Prime) then Exit;

    if not FP2AffinePointFrobenius(Q2, Q, Prime) then Exit;
    if not FP2AffinePointFrobenius(Q2, Q2, Prime) then Exit;

    if not Secant(G, T, Q1, XP, YP, Prime) then Exit;
    if not FP12Mul(F, F, G, Prime) then Exit;

    if not FP2AffinePointAdd(T, T, Q1, Prime) then Exit;

    if not FP2AffinePointNegate(Q2, Q2, Prime) then Exit;
    if not Secant(G, T, Q2, XP, YP, Prime) then Exit;
    if not FP12Mul(F, F, G, Prime) then Exit;

    if not FP2AffinePointAdd(T, T, Q2, Prime) then Exit;

    if not FinalFastExp(F, F, K, Prime) then Exit;
    Result := True;
  finally
    FLocalFP12Pool.Recycle(G);
    FLocalFP2AffinePointPool.Recycle(Q2);
    FLocalFP2AffinePointPool.Recycle(Q1);
    FLocalFP2AffinePointPool.Recycle(T);
  end;
end;

function SM9RatePairing(const F: TCnFP12; const Q: TCnFP2AffinePoint; const P: TCnEccPoint): Boolean;
var
  XP, YP: TCnBigNumber; // P 点坐标的引用
  AQ: TCnFP2AffinePoint;   // Q 点坐标的引用
begin
  if P <> nil then
  begin
    XP := P.X;
    YP := P.Y;
  end
  else // 如果 P 是 nil，则使用 SM9 的曲线的 G1 点
  begin
    XP := FSM9G1P1X;
    YP := FSM9G1P1Y;
  end;

  if Q = nil then // 如果 Q 是 nil，则使用 SM9 曲线的 G2 点
  begin
    AQ := FLocalFP2AffinePointPool.Obtain;
    AQ.SetCoordinatesBigNumbers(FSM9G2P2X0, FSM9G2P2X1, FSM9G2P2Y0, FSM9G2P2Y1);
  end
  else
    AQ := Q;

  // 计算 R-ate 对的值
  Result := Rate(F, AQ, XP, YP, FSM96TPlus2, FSM9FastExpP3, FSM9FiniteFieldSize);

  if Q = nil then
    FLocalFP2AffinePointPool.Recycle(AQ);
end;

{ TCnFP2 }

constructor TCnFP2.Create;
begin
  inherited;
  F0 := TCnBigNumber.Create;
  F1 := TCnBigNumber.Create;
end;

destructor TCnFP2.Destroy;
begin
  F1.Free;
  F0.Free;
  inherited;
end;

function TCnFP2.GetItems(Index: Integer): TCnBigNumber;
begin
  if Index = 0 then
    Result := F0
  else if Index = 1 then
    Result := F1
  else
    raise Exception.CreateFmt(SListIndexError, [Index]);
end;

function TCnFP2.IsOne: Boolean;
begin
  Result := FP2IsOne(Self);
end;

function TCnFP2.IsZero: Boolean;
begin
  Result := FP2IsZero(Self);
end;

function TCnFP2.SetBigNumber(const Num: TCnBigNumber): Boolean;
begin
  Result := FP2SetBigNumber(Self, Num);
end;

function TCnFP2.SetHex(const S0, S1: string): Boolean;
begin
  Result := FP2SetHex(Self, S0, S1);
end;

function TCnFP2.SetOne: Boolean;
begin
  Result := FP2SetOne(Self);
end;

function TCnFP2.SetU: Boolean;
begin
  Result := FP2SetU(Self);
end;

function TCnFP2.SetWord(Value: Cardinal): Boolean;
begin
  Result := FP2SetWord(Self, Value);
end;

function TCnFP2.SetWords(Value0, Value1: Cardinal): Boolean;
begin
  Result := FP2SetWords(Self, Value0, Value1);
end;

function TCnFP2.SetZero: Boolean;
begin
  Result := FP2SetZero(Self);
end;

function TCnFP2.ToString: string;
begin
  Result := FP2ToString(Self);
end;

{ TCnFP4 }

constructor TCnFP4.Create;
begin
  inherited;
  F0 := TCnFP2.Create;
  F1 := TCnFP2.Create;
end;

destructor TCnFP4.Destroy;
begin
  F1.Free;
  F0.Free;
  inherited;
end;

function TCnFP4.GetItems(Index: Integer): TCnFP2;
begin
  if Index = 0 then
    Result := F0
  else if Index = 1 then
    Result := F1
  else
    raise Exception.CreateFmt(SListIndexError, [Index]);
end;

function TCnFP4.IsOne: Boolean;
begin
  Result := FP4IsOne(Self);
end;

function TCnFP4.IsZero: Boolean;
begin
  Result := FP4IsZero(Self);
end;

function TCnFP4.SetBigNumber(const Num: TCnBigNumber): Boolean;
begin
  Result := FP4SetBigNumber(Self, Num);
end;

function TCnFP4.SetBigNumbers(const Num0, Num1: TCnBigNumber): Boolean;
begin
  Result := FP4SetBigNumbers(Self, Num0, Num1);
end;

function TCnFP4.SetHex(const S0, S1, S2, S3: string): Boolean;
begin
  Result := FP4SetHex(Self, S0, S1, S2, S3);
end;

function TCnFP4.SetOne: Boolean;
begin
  Result := FP4SetOne(Self);
end;

function TCnFP4.SetU: Boolean;
begin
  Result := FP4SetU(Self);
end;

function TCnFP4.SetV: Boolean;
begin
  Result := FP4SetV(Self);
end;

function TCnFP4.SetWord(Value: Cardinal): Boolean;
begin
  Result := FP4SetWord(Self, Value);
end;

function TCnFP4.SetWords(Value0, Value1, Value2,
  Value3: Cardinal): Boolean;
begin
  Result := FP4SetWords(Self, Value0, Value1, Value2, Value3);
end;

function TCnFP4.SetZero: Boolean;
begin
  Result := FP4SetZero(Self);
end;

function TCnFP4.ToString: string;
begin
  Result := FP4ToString(Self);
end;

{ TCnFP12 }

constructor TCnFP12.Create;
begin
  inherited;
  F0 := TCnFP4.Create;
  F1 := TCnFP4.Create;
  F2 := TCnFP4.Create;
end;

destructor TCnFP12.Destroy;
begin
  F2.Free;
  F1.Free;
  F0.Free;
  inherited;
end;

function TCnFP12.GetItems(Index: Integer): TCnFP4;
begin
  if Index = 0 then
    Result := F0
  else if Index = 1 then
    Result := F1
  else if Index = 2 then
    Result := F2
  else
    raise Exception.CreateFmt(SListIndexError, [Index]);
end;

function TCnFP12.IsOne: Boolean;
begin
  Result := FP12IsOne(Self);
end;

function TCnFP12.IsZero: Boolean;
begin
  Result := FP12IsZero(Self);
end;

function TCnFP12.SetBigNumber(const Num: TCnBigNumber): Boolean;
begin
  Result := FP12SetBigNumber(Self, Num);
end;

function TCnFP12.SetBigNumbers(const Num0, Num1, Num2: TCnBigNumber): Boolean;
begin
  Result := FP12SetBigNumbers(Self, Num0, Num1, Num2);
end;

function TCnFP12.SetHex(const S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10,
  S11: string): Boolean;
begin
  Result := FP12SetHex(Self, S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11);
end;

function TCnFP12.SetOne: Boolean;
begin
  Result := FP12SetOne(Self);
end;

function TCnFP12.SetU: Boolean;
begin
  Result := FP12SetU(Self);
end;

function TCnFP12.SetV: Boolean;
begin
  Result := FP12SetV(Self);
end;

function TCnFP12.SetW: Boolean;
begin
  Result := FP12SetW(Self);
end;

function TCnFP12.SetWord(Value: Cardinal): Boolean;
begin
  Result := FP12SetWord(Self, Value);
end;

function TCnFP12.SetWords(Value0, Value1, Value2, Value3, Value4, Value5,
  Value6, Value7, Value8, Value9, Value10, Value11: Cardinal): Boolean;
begin
  Result := FP12SetWords(Self, Value0, Value1, Value2, Value3, Value4, Value5,
    Value6, Value7, Value8, Value9, Value10, Value11);
end;

function TCnFP12.SetWSqr: Boolean;
begin
  Result := FP12SetWSqr(Self);
end;

function TCnFP12.SetZero: Boolean;
begin
  Result := FP12SetZero(Self);
end;

function TCnFP12.ToString: string;
begin
  Result := FP12ToString(Self);
end;

{ TCnFP2Pool }

function TCnFP2Pool.CreateObject: TObject;
begin
  Result := TCnFP2.Create;
end;

function TCnFP2Pool.Obtain: TCnFP2;
begin
  Result := TCnFP2(inherited Obtain);
  Result.SetZero;
end;

procedure TCnFP2Pool.Recycle(Num: TCnFP2);
begin
  inherited Recycle(Num);
end;

{ TCnFP4Pool }

function TCnFP4Pool.CreateObject: TObject;
begin
  Result := TCnFP4.Create;
end;

function TCnFP4Pool.Obtain: TCnFP4;
begin
  Result := TCnFP4(inherited Obtain);
  Result.SetZero;
end;

procedure TCnFP4Pool.Recycle(Num: TCnFP4);
begin
  inherited Recycle(Num);
end;

{ TCnFP12Pool }

function TCnFP12Pool.CreateObject: TObject;
begin
  Result := TCnFP12.Create;
end;

function TCnFP12Pool.Obtain: TCnFP12;
begin
  Result := TCnFP12(inherited Obtain);
  Result.SetZero;
end;

procedure TCnFP12Pool.Recycle(Num: TCnFP12);
begin
  inherited Recycle(Num);
end;

{ TCnFP2AffinePoint }

constructor TCnFP2AffinePoint.Create;
begin
  inherited;
  FX := TCnFP2.Create;
  FY := TCnFP2.Create;
  FZ := TCnFP2.Create;
end;

destructor TCnFP2AffinePoint.Destroy;
begin
  FZ.Free;
  FY.Free;
  FX.Free;
  inherited;
end;

function TCnFP2AffinePoint.GetCoordinatesFP2(const FP2X,
  FP2Y: TCnFP2): Boolean;
begin
  Result := FP2AffinePointGetCoordinates(Self, FP2X, FP2Y);
end;

function TCnFP2AffinePoint.GetJacobianCoordinatesFP12(const FP12X, FP12Y: TCnFP12;
  Prime: TCnBigNumber): Boolean;
begin
  Result := FP2AffinePointGetJacobianCoordinates(Self, FP12X, FP12Y, Prime);
end;

function TCnFP2AffinePoint.IsAtInfinity: Boolean;
begin
  Result := FP2AffinePointIsAtInfinity(Self);
end;

function TCnFP2AffinePoint.IsOnCurve(Prime: TCnBigNumber): Boolean;
begin
  Result := FP2AffinePointIsOnCurve(Self, Prime);
end;

function TCnFP2AffinePoint.SetCoordinatesBigNumbers(const X0, X1, Y0,
  Y1: TCnBigNumber): Boolean;
begin
  Result := FP2AffinePointSetCoordinatesBigNumbers(Self, X0, X1, Y0, Y1);
end;

function TCnFP2AffinePoint.SetCoordinatesFP2(const FP2X,
  FP2Y: TCnFP2): Boolean;
begin
  Result := FP2AffinePointSetCoordinates(Self, FP2X, FP2Y);
end;

function TCnFP2AffinePoint.SetCoordinatesHex(const SX0, SX1, SY0,
  SY1: string): Boolean;
begin
  Result := FP2AffinePointSetCoordinatesHex(Self, SX0, SX1, SY0, SY1);
end;

function TCnFP2AffinePoint.SetJacobianCoordinatesFP12(const FP12X, FP12Y: TCnFP12;
  Prime: TCnBigNumber): Boolean;
begin
  Result := FP2AffinePointSetJacobianCoordinates(Self, FP12X, FP12Y, Prime);
end;

function TCnFP2AffinePoint.SetToInfinity: Boolean;
begin
  Result := FP2AffinePointSetToInfinity(Self);
end;

procedure TCnFP2AffinePoint.SetZero;
begin
  FP2AffinePointSetZero(Self);
end;

function TCnFP2AffinePoint.ToString: string;
begin
  Result := FP2AffinePointToString(Self);
end;

{ TCnFP2AffinePointPool }

function TCnFP2AffinePointPool.CreateObject: TObject;
begin
  Result := TCnFP2AffinePoint.Create;
end;

function TCnFP2AffinePointPool.Obtain: TCnFP2AffinePoint;
begin
  Result := TCnFP2AffinePoint(inherited Obtain);
//  Result.SetZero;
end;

procedure TCnFP2AffinePointPool.Recycle(Num: TCnFP2AffinePoint);
begin
  inherited Recycle(Num);
end;

procedure InitSM9Consts;
begin
  FSM9FiniteFieldSize := TCnBigNumber.FromHex(CN_SM9_FINITE_FIELD);
  FSM9Order := TCnBigNumber.FromHex(CN_SM9_ORDER);
  FSM9G1P1X := TCnBigNumber.FromHex(CN_SM9_G1_P1X);
  FSM9G1P1Y := TCnBigNumber.FromHex(CN_SM9_G1_P1Y);
  FSM9G2P2X0 := TCnBigNumber.FromHex(CN_SM9_G2_P2X0);
  FSM9G2P2X1 := TCnBigNumber.FromHex(CN_SM9_G2_P2X1);
  FSM9G2P2Y0 := TCnBigNumber.FromHex(CN_SM9_G2_P2Y0);
  FSM9G2P2Y1 := TCnBigNumber.FromHex(CN_SM9_G2_P2Y1);
  FSM96TPlus2 := TCnBigNumber.FromHex(CN_SM9_6T_PLUS_2);
  FSM9FastExpP3 := TCnBigNumber.FromHex(CN_SM9_FAST_EXP_P3);
  FFP12FastExpPW20 := TCnBigNumber.FromHex(CN_SM9_FAST_EXP_PW20);
  FFP12FastExpPW21 := TCnBigNumber.FromHex(CN_SM9_FAST_EXP_PW21);
  FFP12FastExpPW22 := TCnBigNumber.FromHex(CN_SM9_FAST_EXP_PW22);
  FFP12FastExpPW23 := TCnBigNumber.FromHex(CN_SM9_FAST_EXP_PW23);
end;

procedure FreeSM9Consts;
begin
  FSM9FiniteFieldSize.Free;
  FSM9Order.Free;
  FSM9G1P1X.Free;
  FSM9G1P1Y.Free;
  FSM9G2P2X0.Free;
  FSM9G2P2X1.Free;
  FSM9G2P2Y0.Free;
  FSM9G2P2Y1.Free;
  FSM96TPlus2.Free;
  FSM9FastExpP3.Free;
  FFP12FastExpPW20.Free;
  FFP12FastExpPW21.Free;
  FFP12FastExpPW22.Free;
  FFP12FastExpPW23.Free;
end;

function CnSM9KGCGenerateSignatureMasterKey(SignatureMasterKey:
  TCnSM9SignatureMasterKey; SM9: TCnSM9): Boolean;
var
  C: Boolean;
  AP: TCnFP2AffinePoint;
begin
  Result := False;
  C := SM9 = nil;
  if C then
    SM9 := TCnSM9.Create;

  AP := nil;
  try
    if not BigNumberRandRange(SignatureMasterKey.PrivateKey, SM9.Order) then Exit;
    if SignatureMasterKey.PrivateKey.IsZero then
      SignatureMasterKey.PrivateKey.SetOne;

    AP := TCnFP2AffinePoint.Create;
    if not FP2PointToFP2AffinePoint(AP, SM9.Generator2) then Exit;

    if not FP2AffinePointMul(AP, AP, SignatureMasterKey.PrivateKey, SM9.FiniteFieldSize) then Exit;
    if not FP2AffinePointToFP2Point(SignatureMasterKey.PublicKey, AP, SM9.FiniteFieldSize) then Exit;

    Result := True;
  finally
    AP.Free;
    if C then
      SM9.Free;
  end;
end;

function CnSM9KGCGenerateSignatureUserKey(SignatureMasterPrivateKey: TCnSM9SignatureMasterPrivateKey;
  const AUserID: AnsiString; OutSignatureUserPrivateKey: TCnSM9SignatureUserPrivateKey; SM9: TCnSM9): Boolean;
var
  C: Boolean;
  T1, T2: TCnBigNumber;
  S: AnsiString;
begin
  Result := False;
  C := SM9 = nil;
  if C then
    SM9 := TCnSM9.Create;

  T1 := nil;
  T2 := nil;

  try
    T1 := TCnBigNumber.Create;
    T2 := TCnBigNumber.Create;

    // 计算 T1 := Hash1(ID‖hid，SM9Order) + MasterPrivateKey，注意以下的有限域均是针对 Order 阶，而不是基域 P
    S := AUserID + AnsiChar(CN_SM9_SIGNATURE_USER_HID);
    if not CnSM9Hash1(T1, @S[1], Length(S), SM9.Order) then Exit;

    if not BigNumberAddMod(T1, T1, SignatureMasterPrivateKey, SM9.Order) then Exit;

    if T1.IsZero then
      raise ECnSM9Exception.Create(SSigMasterKeyZero);

    // 计算 T2 = PrivateKey / T1
    if not BigNumberModularInverse(T1, T1, SM9.Order) then Exit;
    if not BigNumberDirectMulMod(T2, SignatureMasterPrivateKey, T1, SM9.Order) then Exit;

    OutSignatureUserPrivateKey.Assign(SM9.Generator);
    SM9.MultiplePoint(T2, OutSignatureUserPrivateKey); // 这里才是有限域 SM9 的 P
    Result := True;
  finally
    T2.Free;
    T1.Free;

    if C then
      SM9.Free;
  end;
end;

function CnSM9UserSignData(SignatureMasterPublicKey: TCnSM9SignatureMasterPublicKey;
  SignatureUserPrivateKey: TCnSM9SignatureUserPrivateKey; PlainData: Pointer;
  DataLen: Integer; OutSignature: TCnSM9Signature; SM9: TCnSM9): Boolean;
var
  C: Boolean;
  G: TCnFP12;
  AP: TCnFP2AffinePoint;
  R, L: TCnBigNumber;
  Stream: TMemoryStream;
begin
  Result := False;
  C := SM9 = nil;
  if C then
    SM9 := TCnSM9.Create;

  G := nil;
  AP := nil;
  R := nil;
  Stream := nil;
  L := nil;

  try
    G := TCnFP12.Create;
    AP := TCnFP2AffinePoint.Create;

    // 先用公钥计算出一个线性对 FP12
    FP2PointToFP2AffinePoint(AP, SignatureMasterPublicKey);
    if not SM9RatePairing(G, AP, SM9.Generator) then Exit;

    R := TCnBigNumber.Create;
    Stream := TMemoryStream.Create;
    L := TCnBigNumber.Create;

    repeat
      // 生成随机 R
      if not BigNumberRandRange(R, SM9.Order) then Exit;
      // 测试数据 R.SetHex('033C8616B06704813203DFD00965022ED15975C662337AED648835DC4B1CBE');
      if R.IsZero then
        R.SetOne;   // 确保范围在 [1, N-1]

      // 计算 G^R 次方
      if not FP12Power(G, G, R, SM9.FiniteFieldSize) then Exit;

      Stream.Clear;
      Stream.Write(PlainData^, DataLen);
      FP12ToStream(G, Stream, SM9.BytesCount);

      if not CnSM9Hash2(OutSignature.H, Stream.Memory, Stream.Size, SM9.Order) then Exit;

      if not BigNumberSub(L, R, OutSignature.H) then Exit;
      if not BigNumberNonNegativeMod(L, L, SM9.Order) then Exit;
    until not L.IsZero;

    // 计算出了 L 和 H，再乘私钥点得到签名
    OutSignature.S.Assign(SignatureUserPrivateKey);
    SM9.MultiplePoint(L, OutSignature.S);
    Result := True;
  finally
    L.Free;
    Stream.Free;
    R.Free;
    AP.Free;
    G.Free;
    if C then
      SM9.Free;
  end;
end;

function CnSM9UserVerifyData(const AUserID: AnsiString; PlainData: Pointer; DataLen: Integer;
  InSignature: TCnSM9Signature; SignatureMasterPublicKey: TCnSM9SignatureMasterPublicKey;
  SM9: TCnSM9): Boolean;
var
  C: Boolean;
  G, W: TCnFP12;
  AP, TP: TCnFP2AffinePoint;
  S: AnsiString;
  H: TCnBigNumber;
  Stream: TMemoryStream;
begin
  Result := False;
  if InSignature.H.IsZero or InSignature.H.IsNegative then Exit;

  C := SM9 = nil;
  if C then
    SM9 := TCnSM9.Create;

  G := nil;
  AP := nil;
  H := nil;
  TP := nil;
  W := nil;
  Stream := nil;

  try
    if BigNumberCompare(InSignature.H, SM9.Order) >= 0 then Exit;
    if not SM9.IsPointOnCurve(InSignature.S) then Exit;

    G := TCnFP12.Create;
    AP := TCnFP2AffinePoint.Create;

    // 先用公钥计算出一个线性对 FP12
    FP2PointToFP2AffinePoint(AP, SignatureMasterPublicKey);
    if not SM9RatePairing(G, AP, SM9.Generator) then Exit;

    // 计算 FP12 的幂
    if not FP12Power(G, G, InSignature.H, SM9.FiniteFieldSize) then Exit;

    H := TCnBigNumber.Create;
    // 计算 H1
    S := AUserID + AnsiChar(CN_SM9_SIGNATURE_USER_HID);
    if not CnSM9Hash1(H, @S[1], Length(S), SM9.Order) then Exit;

    // 计算 G2 域上的 H1*P2
    if not FP2PointToFP2AffinePoint(AP, SM9.Generator2) then Exit;
    if not FP2AffinePointMul(AP, AP, H, SM9.FiniteFieldSize) then Exit;

    // 并加上 Pub，结果放 TP 里
    TP := TCnFP2AffinePoint.Create;
    if not FP2PointToFP2AffinePoint(TP, SignatureMasterPublicKey) then Exit;
    if not FP2AffinePointAdd(TP, AP, TP, SM9.FiniteFieldSize) then Exit;

    // 再计算一个双线性对 e(S, P)
    W := TCnFP12.Create;
    if not SM9RatePairing(W, TP, InSignature.S) then Exit;

    // W 再和 G 相乘
    if not FP12Mul(W, W, G, SM9.FiniteFieldSize) then Exit;

    Stream := TMemoryStream.Create;
    Stream.Write(PlainData^, DataLen);
    FP12ToStream(W, Stream, SM9.BytesCount);

    // 再次拼上原文与 FP12 计算 Hash2 并比对
    if not CnSM9Hash2(H, Stream.Memory, Stream.Size, SM9.Order) then Exit;
    Result := BigNumberEqual(H, InSignature.H);
  finally
    Stream.Free;
    W.Free;
    TP.Free;
    H.Free;
    AP.Free;
    G.Free;
    if C then
      SM9.Free;
  end;
end;

function CnSM9KGCGenerateEncryptionMasterKey(EncryptionMasterKey:
  TCnSM9EncryptionMasterKey; SM9: TCnSM9): Boolean;
var
  C: Boolean;
begin
  C := SM9 = nil;
  if C then
    SM9 := TCnSM9.Create;

  try
    BigNumberRandRange(EncryptionMasterKey.PrivateKey, SM9.Order);
    if EncryptionMasterKey.PrivateKey.IsZero then
      EncryptionMasterKey.PrivateKey.SetOne;

    EncryptionMasterKey.PublicKey.Assign(SM9.Generator);
    SM9.MultiplePoint(EncryptionMasterKey.PrivateKey, EncryptionMasterKey.PublicKey);

    Result := True;
  finally
    if C then
      SM9.Free;
  end;
end;

function CnSM9KGCGenerateEncryptionUserKey(EncryptionMasterPrivateKey: TCnSm9EncryptionMasterPrivateKey;
  const AUserID: AnsiString; OutEncryptionUserKey: TCnSM9EncryptionUserPrivateKey; SM9: TCnSM9): Boolean;
var
  C: Boolean;
  S: AnsiString;
  T1: TCnBigNumber;
  AP: TCnFP2AffinePoint;
begin
  Result := False;
  C := SM9 = nil;
  if C then
    SM9 := TCnSM9.Create;

  T1 := nil;
  AP := nil;

  try
    S := AUserID + AnsiChar(CN_SM9_KEY_ENCAPSULATION_USER_HID);

    T1 := TCnBigNumber.Create;
    if not CnSM9Hash1(T1, @S[1], Length(S), SM9.Order) then Exit;

    if not BigNumberAdd(T1, T1, EncryptionMasterPrivateKey) then Exit;

    if T1.IsZero then
      raise ECnSM9Exception.Create(SEncMasterKeyZero);

    if not BigNumberModularInverse(T1, T1, SM9.Order) then Exit;

    if not BigNumberDirectMulMod(T1, T1, EncryptionMasterPrivateKey, SM9.Order) then Exit;

    AP := TCnFP2AffinePoint.Create;
    if not FP2PointToFP2AffinePoint(AP, SM9.Generator2) then Exit;
    if not FP2AffinePointMul(AP, AP, T1, SM9.FiniteFieldSize) then Exit;
    if not FP2AffinePointToFP2Point(OutEncryptionUserKey, AP, SM9.FiniteFieldSize) then Exit;

    Result := True;
  finally
    AP.Free;
    T1.Free;
    if C then
      SM9.Free;
  end;
end;

function CnSM9UserSendKeyEncapsulation(const DestUserID: AnsiString; KeyByteLength: Integer;
 EncryptionPublicKey: TCnSM9EncryptionMasterPublicKey;
 OutKeyEncapsulation: TCnSM9KeyEncapsulation; SM9: TCnSM9): Boolean;
var
  C: Boolean;
  S: AnsiString;
  H, R: TCnBigNumber;
  AP: TCnFP2AffinePoint;
  G: TCnFP12;
  Stream: TMemoryStream;
begin
  Result := False;
  C := SM9 = nil;
  if C then
    SM9 := TCnSM9.Create;

  H := nil;
  R := nil;
  AP := nil;
  G := nil;
  Stream := nil;

  try
    S := DestUserID + AnsiChar(CN_SM9_KEY_ENCAPSULATION_USER_HID);
    H := TCnBigNumber.Create;

    if not CnSM9Hash1(H, @S[1], Length(S), SM9.Order) then Exit;

    OutKeyEncapsulation.Code.Assign(SM9.Generator);
    SM9.MultiplePoint(H, OutKeyEncapsulation.Code);
    SM9.PointAddPoint(EncryptionPublicKey, OutKeyEncapsulation.Code, OutKeyEncapsulation.Code);

    R := TCnBigNumber.Create;
    if not BigNumberRandRange(R, SM9.Order) then Exit;
    // 测试数据 R.SetHex('74015F8489C01EF4270456F9E6475BFB602BDE7F33FD482AB4E3684A6722');
    if R.IsZero then
      R.SetOne;

    SM9.MultiplePoint(R, OutKeyEncapsulation.Code); // 得到封装密文 C

    AP := TCnFP2AffinePoint.Create;
    if not FP2PointToFP2AffinePoint(AP, SM9.Generator2) then Exit;

    G := TCnFP12.Create;
    if not SM9RatePairing(G, AP, EncryptionPublicKey) then Exit;
    if not FP12Power(G, G, R, SM9.FiniteFieldSize) then Exit;

    Stream := TMemoryStream.Create;
    CnEccPointToStream(OutKeyEncapsulation.Code, Stream, SM9.BytesCount);
    FP12ToStream(G, Stream, SM9.BytesCount);
    Stream.Write(DestUserID[1], Length(DestUserID));

    OutKeyEncapsulation.Key := CnSM9KDF(Stream.Memory, Stream.Size, KeyByteLength); // 得到封装密钥 K
    Result := KeyByteLength = Length(OutKeyEncapsulation.Key);
  finally
    Stream.Free;
    G.Free;
    AP.Free;
    R.Free;
    H.Free;
    if C then
      SM9.Free;
  end;
end;

function CnSM9UserReceiveKeyEncapsulation(const DestUserID: AnsiString;
  EncryptionUserKey: TCnSM9EncryptionUserPrivateKey; KeyByteLength: Integer;
  InKeyEncapsulationC: TCnSM9KeyEncapsulationCode; out Key: AnsiString; SM9: TCnSM9): Boolean;
var
  C: Boolean;
  W: TCnFP12;
  AP: TCnFP2AffinePoint;
  Stream: TMemoryStream;
begin
  Result := False;
  C := SM9 = nil;
  if C then
    SM9 := TCnSM9.Create;

  W := nil;
  AP := nil;
  Stream := nil;

  try
    if not SM9.IsPointOnCurve(InKeyEncapsulationC) then Exit;

    W := TCnFP12.Create;
    AP := TCnFP2AffinePoint.Create;
    if not FP2PointToFP2AffinePoint(AP, EncryptionUserKey) then Exit;
    if not SM9RatePairing(W, AP, InKeyEncapsulationC) then Exit;

    Stream := TMemoryStream.Create;
    CnEccPointToStream(InKeyEncapsulationC, Stream, SM9.BytesCount);
    FP12ToStream(W, Stream, SM9.BytesCount);
    Stream.Write(DestUserID[1], Length(DestUserID));

    Key := CnSM9KDF(Stream.Memory, Stream.Size, KeyByteLength);
    Result := Key <> '';
  finally
    Stream.Free;
    AP.Free;
    W.Free;
    if C then
      SM9.Free;
  end;
end;

{
   C1 是一个 EccPoint，长度为两个 32 字节共 64 字节
   C2 是密文值，XOR 模式下长度等于明文值、SM4 模式下长度等于明文的 PKCS7 对齐长度
   C3 是一个 Mac 值，用 SM3 计算，长度 32 字节
   密文为：C1‖C3‖C2
}
function CnSM9UserEncryptData(const DestUserID: AnsiString;
  EncryptionPublicKey: TCnSM9EncryptionMasterPublicKey; PlainData: Pointer;
  DataLen: Integer; K1ByteLength, K2ByteLength: Integer; OutStream: TStream;
  EncryptionMode: TCnSM9EncrytionMode; SM9: TCnSM9): Boolean;
var
  C: Boolean;
  S, KDFKey: AnsiString;
  H, R: TCnBigNumber;
  Q: TCnEccPoint;
  AP: TCnFP2AffinePoint;
  G: TCnFP12;
  Stream: TMemoryStream;
  I, KLen: Integer;
  P2, C2: array of Byte;
  PD: PByteArray;
  Mac: TSM3Digest;

  procedure BytesAddPKCS7Padding(BlockSize: Byte);
  var
    Rb: Byte;
    L, J: Integer;
  begin
    L := Length(P2);
    Rb := L mod BlockSize;
    Rb := BlockSize - Rb;
    if Rb = 0 then
      Rb := Rb + BlockSize;

    SetLength(P2, L + Rb);
    for J := 0 to Rb - 1 do
      P2[L + J] := Rb;
  end;

begin
  Result := False;
  if (DestUserID = '') or (PlainData = nil) or (DataLen <= 0) or (K1ByteLength <= 0)
    or (K2ByteLength <= 0) then
    Exit;

  // SM4 的 Key 长度只能 16
  if EncryptionMode = semSM4 then
    K1ByteLength := SM4_KEYSIZE;

  C := SM9 = nil;
  if C then
    SM9 := TCnSM9.Create;

  H := nil;
  Q := nil;
  R := nil;
  AP := nil;
  G := nil;
  Stream := nil;
  C2 := nil;
  P2 := nil;

  try
    S := DestUserID + AnsiChar(CN_SM9_ENCRYPTION_USER_HID);
    H := TCnBigNumber.Create;

    if not CnSM9Hash1(H, @S[1], Length(S), SM9.Order) then Exit;

    Q := TCnEccPoint.Create;
    Q.Assign(SM9.Generator);
    SM9.MultiplePoint(H, Q);
    SM9.PointAddPoint(EncryptionPublicKey, Q, Q);

    R := TCnBigNumber.Create;
    if not BigNumberRandRange(R, SM9.Order) then Exit;
    // 测试数据 R.SetHex('AAC0541779C8FC45E3E2CB25C12B5D2576B2129AE8BB5EE2CBE5EC9E785C');
    if R.IsZero then
      R.SetOne;

    SM9.MultiplePoint(R, Q); // Q 得到 C1

    AP := TCnFP2AffinePoint.Create;
    if not FP2PointToFP2AffinePoint(AP, SM9.Generator2) then Exit;

    G := TCnFP12.Create;
    if not SM9RatePairing(G, AP, EncryptionPublicKey) then Exit;
    if not FP12Power(G, G, R, SM9.FiniteFieldSize) then Exit; // G 得到幂 w

    Stream := TMemoryStream.Create;
    CnEccPointToStream(Q, Stream, SM9.BytesCount);
    FP12ToStream(G, Stream, SM9.BytesCount);
    Stream.Write(DestUserID[1], Length(DestUserID));

    KLen := 0; // 初始化一下
    if EncryptionMode = semSM4 then
    begin
      KLen := K1ByteLength + K2ByteLength;
      KDFKey := CnSM9KDF(Stream.Memory, Stream.Size, KLen);

      SetLength(P2, DataLen);
      Move(PlainData^, P2[0], DataLen);
      BytesAddPKCS7Padding(SM4_BLOCKSIZE); // 复制原始数据并在尾部加上几个几的 PKCS7 对齐

      SetLength(C2, Length(P2));

      // 使用 KDFKey 的 1 到 K1Length 作为密码来 SM4 加密对齐后的明文并放到 C2 中
      SM4Encrypt(@KDFKey[1], @P2[0], @C2[0], Length(P2));
    end
    else if EncryptionMode = semXOR then
    begin
      KLen := DataLen + K2ByteLength;
      KDFKey := CnSM9KDF(Stream.Memory, Stream.Size, KLen);

      // KDFKey 的 1 到 DataLen 与明文异或得到 C2，注意 KDFKey 的下标从 1 开始
      PD := PByteArray(PlainData);
      SetLength(C2, DataLen);

      for I := 0 to DataLen - 1 do
        C2[I] := Byte(KDFKey[I + 1]) xor PD^[I];
    end;

    Mac := SM9Mac(@(KDFKey[KLen - K2ByteLength + 1]), K2ByteLength, @C2[0], Length(C2)); // 用 K2 和 C2 算出 C3

    CnEccPointToStream(Q, OutStream, SM9.BytesCount);             // 写 C1
    OutStream.Write(Mac[0], SizeOf(TSM3Digest));  // 写 C3
    OutStream.Write(C2[0], Length(C2));           // 写 C2

    Result := True;
  finally
    SetLength(P2, 0);
    SetLength(C2, 0);
    Stream.Free;
    G.Free;
    AP.Free;
    R.Free;
    Q.Free;
    H.Free;
    if C then
      SM9.Free;
  end;
end;

function CnSM9UserDecryptData(const DestUserID: AnsiString;
  EncryptionUserKey: TCnSM9EncryptionUserPrivateKey; EnData: Pointer;
  DataLen: Integer; K2ByteLength: Integer; OutStream: TStream;
  EncryptionMode: TCnSM9EncrytionMode; SM9: TCnSM9): Boolean;
var
  C: Boolean;
  C1: TCnEccPoint;
  C3, Mac: TSM3Digest;
  P: PByteArray;
  PC: PAnsiChar;
  AP: TCnFP2AffinePoint;
  W: TCnFP12;
  Stream: TMemoryStream;
  KLen, I, MLen: Integer;
  KDFKey: AnsiString;
  C2: array of Byte;

  procedure BytesRemovePKCS7Padding;
  var
    L: Integer;
    V: Byte;
  begin
    L := Length(C2);
    if L = 0 then
      Exit;

    V := Ord(C2[L - 1]);  // 末是几表示加了几

    if V <= L then
      SetLength(C2, L - V);
  end;

begin
  Result := False;
  if (EnData = nil) or (K2ByteLength <= 0) or (DataLen <= 0) then
    Exit;

  C := SM9 = nil;
  if C then
    SM9 := TCnSM9.Create;

  if DataLen <= (SM9.BitsCount div 4) + SizeOf(TSM3Digest) then
    Exit;

  C1 := nil;
  AP := nil;
  W := nil;
  Stream := nil;
  C2 := nil;

  // 密文前 2 * SM9.BitsCount div 8 个字节是 C1 这个 EccPoint 的二进制形式

  try
    PC := PAnsiChar(EnData);
    C1 := TCnEccPoint.Create;
    C1.X.SetBinary(PC, SM9.BitsCount div 8);
    Inc(PC, SM9.BitsCount div 8);
    C1.Y.SetBinary(PC, SM9.BitsCount div 8);

    // 先判断是否在曲线上
    if not SM9.IsPointOnCurve(C1) then Exit;

    Inc(PC, SM9.BitsCount div 8);
    Move(PC^, C3[0], SizeOf(TSM3Digest)); // 取出 C3 以备比较
    Inc(PC, SizeOf(TSM3Digest));  // PC 现在指向密文 C2

    P := PByteArray(PC);
    MLen := DataLen - SM9.BitsCount div 4 - SizeOf(TSM3Digest); // MLen 密文长度

    AP := TCnFP2AffinePoint.Create;
    if not FP2PointToFP2AffinePoint(AP, EncryptionUserKey) then Exit;
    W := TCnFP12.Create;
    if not SM9RatePairing(W, AP, C1) then Exit;

    Stream := TMemoryStream.Create;
    CnEccPointToStream(C1, Stream, SM9.BytesCount);
    FP12ToStream(W, Stream, SM9.BytesCount);
    Stream.Write(DestUserID[1], Length(DestUserID));

    SetLength(C2, MLen);
    if EncryptionMode = semSM4 then
    begin
      KLen := SM4_KEYSIZE + K2ByteLength;
      KDFKey := CnSM9KDF(Stream.Memory, Stream.Size, KLen);
      Mac := SM9Mac(@(KDFKey[KLen - K2ByteLength + 1]), K2ByteLength, @P[0], MLen); // 用 K2 和 C2 算出 C3

      // SK4 解出明文到 C2
      SM4Decrypt(@KDFKey[1], @P[0], @C2[0], Length(C2));
      // 去掉 C2 尾部的 PKCS7 内容即为明文
      BytesRemovePKCS7Padding;
    end
    else if EncryptionMode = semXOR then
    begin
      KLen := MLen + K2ByteLength;
      KDFKey := CnSM9KDF(Stream.Memory, Stream.Size, KLen);
      Mac := SM9Mac(@(KDFKey[KLen - K2ByteLength + 1]), K2ByteLength, @P[0], MLen); // 用 K2 和 C2 算出 C3

      // KDFKey 的前面部分的长度与与密文相等，XOR 出结果即为明文
      for I := 0 to Length(C2) - 1 do
        C2[I] := Byte(KDFKey[I + 1]) xor P^[I];
    end;

    if CompareMem(@C3[0], @Mac[0], SizeOf(TSM3Digest)) then
    begin
      OutStream.Write(C2[0], Length(C2));
      Result := True;
    end;
  finally
    SetLength(C2, 0);
    Stream.Free;
    W.Free;
    AP.Free;
    C1.Free;
    if C then
      SM9.Free;
  end;
end;

// ====================== SM9 具体实现函数：密钥协商 ===========================

function CnSM9KGCGenerateKeyExchangeMasterKey(KeyExchangeMasterKey:
  TCnSM9KeyExchangeMasterKey; SM9: TCnSM9 = nil): Boolean;
var
  C: Boolean;
begin
  C := SM9 = nil;
  if C then
    SM9 := TCnSM9.Create;

  try
    BigNumberRandRange(KeyExchangeMasterKey.PrivateKey, SM9.Order);
    if KeyExchangeMasterKey.PrivateKey.IsZero then
      KeyExchangeMasterKey.PrivateKey.SetOne;

    KeyExchangeMasterKey.PublicKey.Assign(SM9.Generator);
    SM9.MultiplePoint(KeyExchangeMasterKey.PrivateKey, KeyExchangeMasterKey.PublicKey);

    Result := True;
  finally
    if C then
      SM9.Free;
  end;
end;

function CnSM9KGCGenerateKeyExchangeUserKey(KeyExchangeMasterPrivateKey:
  TCnSM9KeyExchangeMasterPrivateKey; const AUserID: AnsiString;
  OutKeyExchangeUserKey: TCnSM9KeyExchangeUserPrivateKey; SM9: TCnSM9 = nil): Boolean;
var
  C: Boolean;
  S: AnsiString;
  T1: TCnBigNumber;
  AP: TCnFP2AffinePoint;
begin
  Result := False;
  C := SM9 = nil;
  if C then
    SM9 := TCnSM9.Create;

  T1 := nil;
  AP := nil;

  try
    S := AUserID + AnsiChar(CN_SM9_KEY_EXCHANGE_USER_HID);

    T1 := TCnBigNumber.Create;
    if not CnSM9Hash1(T1, @S[1], Length(S), SM9.Order) then Exit;

    if not BigNumberAdd(T1, T1, KeyExchangeMasterPrivateKey) then Exit;

    if T1.IsZero then
      raise ECnSM9Exception.Create(SEncMasterKeyZero);

    if not BigNumberModularInverse(T1, T1, SM9.Order) then Exit;

    if not BigNumberDirectMulMod(T1, T1, KeyExchangeMasterPrivateKey, SM9.Order) then Exit;

    AP := TCnFP2AffinePoint.Create;
    if not FP2PointToFP2AffinePoint(AP, SM9.Generator2) then Exit;
    if not FP2AffinePointMul(AP, AP, T1, SM9.FiniteFieldSize) then Exit;
    if not FP2AffinePointToFP2Point(OutKeyExchangeUserKey, AP, SM9.FiniteFieldSize) then Exit;

    Result := True;
  finally
    AP.Free;
    T1.Free;
    if C then
      SM9.Free;
  end;
end;

function CnSM9UserKeyExchangeAStep1(const BUserID: AnsiString; KeyByteLength: Integer;
  KeyExchangePublicKey: TCnSM9KeyExchangeMasterPublicKey; OutRA: TCnEccPoint;
  OutRandA: TCnBigNumber; SM9: TCnSM9 = nil): Boolean;
var
  C: Boolean;
  S: AnsiString;
  T: TCnBigNumber;
begin
  Result := False;
  C := SM9 = nil;
  if C then
    SM9 := TCnSM9.Create;

  T := nil;

  try
    S := BUserID + AnsiChar(CN_SM9_KEY_EXCHANGE_USER_HID);
    T := TCnBigNumber.Create;
    if not CnSM9Hash1(T, @S[1], Length(S), SM9.Order) then Exit;

    OutRA.Assign(SM9.Generator);
    SM9.MultiplePoint(T, OutRA);
    SM9.PointAddPoint(OutRA, KeyExchangePublicKey, OutRA);

    if not BigNumberRandRange(OutRandA, SM9.Order) then Exit;
    // 测试数据 OutRandA.SetHex('5879DD1D51E175946F23B1B41E93BA31C584AE59A426EC1046A4D03B06C8');
    if OutRandA.IsZero then
      OutRandA.SetOne;

    SM9.MultiplePoint(OutRandA, OutRA);
    Result := True;
  finally
    T.Free;
    if C then
      SM9.Free;
  end;
end;

function CnSM9UserKeyExchangeBStep1(const AUserID, BUserID: AnsiString;
  KeyByteLength: Integer; KeyExchangePublicKey: TCnSM9KeyExchangeMasterPublicKey;
  KeyExchangeBUserKey: TCnSM9KeyExchangeUserPrivateKey; InRA: TCnEccPoint;
  OutRB: TCnEccPoint; out KeyB: AnsiString; out OutOptionalSB: TSM3Digest;
  OutG1, OutG2, OutG3: TCnFP12; SM9: TCnSM9 = nil): Boolean;
var
  C: Boolean;
  S: AnsiString;
  R, T: TCnBigNumber;
  AP: TCnFP2AffinePoint;
  Stream: TMemoryStream;
  B: Byte;
  D: TSM3Digest;
begin
  Result := False;

  if (InRA = nil) or (KeyByteLength <= 0) or
    (OutG1 = nil) or (OutG2 = nil) or (OutG3 = nil) then Exit;

  C := SM9 = nil;
  if C then
    SM9 := TCnSM9.Create;

  T := nil;
  R := nil;
  AP := nil;
  Stream := nil;

  try
    if not SM9.IsPointOnCurve(InRA) then Exit;

    S := AUserID + AnsiChar(CN_SM9_KEY_EXCHANGE_USER_HID);
    T := TCnBigNumber.Create;
    if not CnSM9Hash1(T, @S[1], Length(S), SM9.Order) then Exit;

    OutRB.Assign(SM9.Generator);
    SM9.MultiplePoint(T, OutRB);
    SM9.PointAddPoint(OutRB, KeyExchangePublicKey, OutRB);

    R := TCnBigNumber.Create;
    if not BigNumberRandRange(R, SM9.Order) then Exit;
    // 测试数据 R.SetHex('018B98C44BEF9F8537FB7D071B2C928B3BC65BD3D69E1EEE213564905634FE');
    if R.IsZero then
      R.SetOne;

    SM9.MultiplePoint(R, OutRB);

    AP := TCnFP2AffinePoint.Create;

    if not FP2PointToFP2AffinePoint(AP, KeyExchangeBUserKey) then Exit;
    if not SM9RatePairing(OutG1, AP, InRA) then Exit;

    if not FP2PointToFP2AffinePoint(AP, SM9.Generator2) then Exit;
    if not SM9RatePairing(OutG2, AP, KeyExchangePublicKey) then Exit;
    if not FP12Power(OutG2, OutG2, R, SM9.FiniteFieldSize) then Exit;

    if not FP12Power(OutG3, OutG1, R, SM9.FiniteFieldSize) then Exit; // 计算出了仨 G

    Stream := TMemoryStream.Create;
    Stream.Write(AUserID[1], Length(AUserID));
    Stream.Write(BUserID[1], Length(BUserID));
    CnEccPointToStream(InRA, Stream, SM9.BytesCount);
    CnEccPointToStream(OutRB, Stream, SM9.BytesCount);
    FP12ToStream(OutG1, Stream, SM9.BytesCount);
    FP12ToStream(OutG2, Stream, SM9.BytesCount);
    FP12ToStream(OutG3, Stream, SM9.BytesCount);

    KeyB := CnSM9KDF(Stream.Memory, Stream.Size, KeyByteLength); // 生成了协商密钥

    // 再计算可选的校验值
    Stream.Clear;
    FP12ToStream(OutG2, Stream, SM9.BytesCount);
    FP12ToStream(OutG3, Stream, SM9.BytesCount);
    Stream.Write(AUserID[1], Length(AUserID));
    Stream.Write(BUserID[1], Length(BUserID));
    CnEccPointToStream(InRA, Stream, SM9.BytesCount);
    CnEccPointToStream(OutRB, Stream, SM9.BytesCount);
    D := SM3(Stream.Memory, Stream.Size);  // 第一次 Hash

    Stream.Clear;
    B := CN_SM9_KEY_EXCHANGE_HASHID1;
    Stream.Write(B, 1);
    FP12ToStream(OutG1, Stream, SM9.BytesCount);
    Stream.Write(D[0], SizeOf(TSM3Digest));
    OutOptionalSB := SM3(Stream.Memory, Stream.Size); // 第二次 Hash

    Result := True;
  finally
    Stream.Free;
    AP.Free;
    R.Free;
    T.Free;
    if C then
      SM9.Free;
  end;
end;

function CnSM9UserKeyExchangeAStep2(const AUserID, BUserID: AnsiString; KeyByteLength: Integer;
  KeyExchangePublicKey: TCnSM9KeyExchangeMasterPublicKey;
  KeyExchangeAUserKey: TCnSM9KeyExchangeUserPrivateKey; InRandA: TCnBigNumber;
  InRA, InRB: TCnEccPoint; InOptionalSB: TSM3Digest; out KeyA: AnsiString;
  out OutOptionalSA: TSM3Digest; SM9: TCnSM9 = nil): Boolean;
var
  C: Boolean;
  G1, G2, G3: TCnFP12;
  AP: TCnFP2AffinePoint;
  Stream: TMemoryStream;
  B: Byte;
  D: TSM3Digest;
begin
  Result := False;
  if (InRA = nil) or (InRB = nil) or (InRandA = nil) then Exit;

  C := SM9 = nil;
  if C then
    SM9 := TCnSM9.Create;

  AP := nil;
  G1 := nil;
  G2 := nil;
  G3 := nil;
  Stream := nil;

  try
    if not SM9.IsPointOnCurve(InRB) then Exit;

    AP := TCnFP2AffinePoint.Create;
    FP2PointToFP2AffinePoint(AP, SM9.Generator2);

    G1 := TCnFP12.Create;
    if not SM9RatePairing(G1, AP, KeyExchangePublicKey) then Exit;
    if not FP12Power(G1, G1, InRandA, SM9.FiniteFieldSize) then Exit;

    G2 := TCnFP12.Create;
    FP2PointToFP2AffinePoint(AP, KeyExchangeAUserKey);
    if not SM9RatePairing(G2, AP, InRB) then Exit;

    G3 := TCnFP12.Create;
    if not FP12Power(G3, G2, InRandA, SM9.FiniteFieldSize) then Exit; // 也计算出了仨 G

    Stream := TMemoryStream.Create;
    FP12ToStream(G2, Stream, SM9.BytesCount);
    FP12ToStream(G3, Stream, SM9.BytesCount);
    Stream.Write(AUserID[1], Length(AUserID));
    Stream.Write(BUserID[1], Length(BUserID));
    CnEccPointToStream(InRA, Stream, SM9.BytesCount);
    CnEccPointToStream(InRB, Stream, SM9.BytesCount);
    D := SM3(Stream.Memory, Stream.Size); // 第一次 Hash

    Stream.Clear;
    B := CN_SM9_KEY_EXCHANGE_HASHID1;
    Stream.Write(B, 1);
    FP12ToStream(G1, Stream, SM9.BytesCount);
    Stream.Write(D[0], SizeOf(TSM3Digest));
    D := SM3(Stream.Memory, Stream.Size); // 第二次 Hash

    if not CompareMem(@D[0], @InOptionalSB[0], SizeOf(TSM3Digest)) then Exit;

    // 校验 SA SB 通过后，开始计算密钥
    Stream.Clear;
    Stream.Write(AUserID[1], Length(AUserID));
    Stream.Write(BUserID[1], Length(BUserID));
    CnEccPointToStream(InRA, Stream, SM9.BytesCount);
    CnEccPointToStream(InRB, Stream, SM9.BytesCount);
    FP12ToStream(G1, Stream, SM9.BytesCount);
    FP12ToStream(G2, Stream, SM9.BytesCount);
    FP12ToStream(G3, Stream, SM9.BytesCount);

    KeyA := CnSM9KDF(Stream.Memory, Stream.Size, KeyByteLength); // 生成了协商密钥

    // 可选：再来一把校验
    Stream.Clear;
    FP12ToStream(G2, Stream, SM9.BytesCount);
    FP12ToStream(G3, Stream, SM9.BytesCount);
    Stream.Write(AUserID[1], Length(AUserID));
    Stream.Write(BUserID[1], Length(BUserID));
    CnEccPointToStream(InRA, Stream, SM9.BytesCount);
    CnEccPointToStream(InRB, Stream, SM9.BytesCount);
    D := SM3(Stream.Memory, Stream.Size); // 第一次 Hash

    Stream.Clear;
    B := CN_SM9_KEY_EXCHANGE_HASHID2;
    Stream.Write(B, 1);
    FP12ToStream(G1, Stream, SM9.BytesCount);
    Stream.Write(D[0], SizeOf(TSM3Digest));
    OutOptionalSA := SM3(Stream.Memory, Stream.Size); // 第二次 Hash

    Result := True;
  finally
    Stream.Free;
    AP.Free;
    G3.Free;
    G2.Free;
    G1.Free;
    if C then
      SM9.Free;
  end;
end;

function CnSM9UserKeyExchangeBStep2(const AUserID, BUserID: AnsiString;
  InRA, InRB: TCnEccPoint; InOptionalSA: TSM3Digest; InG1, InG2, InG3: TCnFP12;
  SM9: TCnSM9 = nil): Boolean;
var
  C: Boolean;
  D: TSM3Digest;
  Stream: TMemoryStream;
  B: Byte;
begin
  Result := False;

  if (InRA = nil) or (InRB = nil) or
    (InG1 = nil) or (InG2 = nil) or (InG3 = nil) then Exit;

  C := SM9 = nil;
  if C then
    SM9 := TCnSM9.Create;

  Stream := nil;

  try
    Stream := TMemoryStream.Create;

    FP12ToStream(InG2, Stream, SM9.BytesCount);
    FP12ToStream(InG3, Stream, SM9.BytesCount);
    Stream.Write(AUserID[1], Length(AUserID));
    Stream.Write(BUserID[1], Length(BUserID));
    CnEccPointToStream(InRA, Stream, SM9.BytesCount);
    CnEccPointToStream(InRB, Stream, SM9.BytesCount);

    D := SM3(Stream.Memory, Stream.Size);
    Stream.Clear;
    B := CN_SM9_KEY_EXCHANGE_HASHID2;

    Stream.Write(B, 1);
    FP12ToStream(InG1, Stream, SM9.BytesCount);
    Stream.Write(D[0], SizeOf(TSM3Digest));

    // 第二次 Hash
    D := SM3(Stream.Memory, Stream.Size);
    Result := CompareMem(@D[0], @InOptionalSA[0], SizeOf(TSM3Digest));
  finally
    Stream.Free;
    if C then
      SM9.Free;
  end;
end;

function StrToHex(Value: PAnsiChar; Len: Integer): AnsiString;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Len - 1 do
    Result := Result + IntToHex(Ord(Value[I]), 2);
end;

function SM9Hash(const Res: TCnBigNumber; Prefix: Byte; Data: Pointer; DataLen: Integer;
  N: TCnBigNumber): Boolean;
var
  CT, SCT, HLen: LongWord;
  I, CeilLen: Integer;
  IsInt: Boolean;
  DArr, Ha: array of Byte; // Ha 长 HLen Bits
  SM3D: TSM3Digest;
  BH, BN: TCnBigNumber;

  function SwapLongWord(Value: LongWord): LongWord;
  begin
    Result := ((Value and $000000FF) shl 24) or ((Value and $0000FF00) shl 8)
      or ((Value and $00FF0000) shr 8) or ((Value and $FF000000) shr 24);
  end;

begin
  Result := False;
  if (Data = nil) or (DataLen <= 0) then
    Exit;

  DArr := nil;
  Ha := nil;
  BH := nil;
  BN := nil;

  // 当 N 有 256 Bits 时

  try
    CT := 1;
    HLen := ((N.GetBitsCount * 5 + 31) div 32);
    HLen := 8 * HLen;
    // HLen 是一个 Bits 数，等于最后 Ha 的比特长度，而且在 SM9 里应该能被 8 整除也就是符合整字节数
    // N = 256 Bits 时 HLen = 320

    IsInt := HLen mod CN_SM3_DIGEST_BITS = 0;
    CeilLen := (HLen + CN_SM3_DIGEST_BITS - 1) div CN_SM3_DIGEST_BITS;

    // CeilLen = 2，FloorLen = 1

    SetLength(DArr, DataLen + SizeOf(Byte) + SizeOf(LongWord)); // 1 Byte Prefix + 4 Byte Cardinal CT
    DArr[0] := Prefix;
    Move(Data^, DArr[1], DataLen);

    SetLength(Ha, HLen div 8);

    for I := 1 to CeilLen do
    begin
      SCT := SwapLongWord(CT);  // 虽然文档中没说，但要倒序一下
      Move(SCT, DArr[DataLen + 1], SizeOf(LongWord));
      SM3D := SM3(@DArr[0], Length(DArr));

      if (I = CeilLen) and not IsInt then
      begin
        // 是最后一个，不整除时只移动一部分
        Move(SM3D[0], Ha[(I - 1) * SizeOf(TSM3Digest)], (HLen mod CN_SM3_DIGEST_BITS) div 8);
      end
      else
        Move(SM3D[0], Ha[(I - 1) * SizeOf(TSM3Digest)], SizeOf(TSM3Digest));

      Inc(CT);
    end;

    BN := BigNumberDuplicate(N);
    BN.SubWord(1);

    BH := TCnBigNumber.FromBinary(PAnsiChar(@Ha[0]), Length(Ha));
    Result := BigNumberNonNegativeMod(Res, BH, BN);
    Res.AddWord(1);
  finally
    BN.Free;
    BH.Free;
    SetLength(Ha, 0);
    SetLength(DArr, 0);
  end;
end;

function CnSM9Hash1(const Res: TCnBigNumber; Data: Pointer; DataLen: Integer;
  N: TCnBigNumber): Boolean;
begin
  Result := SM9Hash(Res, CN_SM9_HASH_PREFIX_1, Data, DataLen, N);
end;

function CnSM9Hash2(const Res: TCnBigNumber; Data: Pointer; DataLen: Integer;
  N: TCnBigNumber): Boolean;
begin
  Result := SM9Hash(Res, CN_SM9_HASH_PREFIX_2, Data, DataLen, N);
end;

function SM9Mac(Key: Pointer; KeyByteLength: Integer; Z: Pointer; ZByteLength: Integer): TSM3Digest;
var
  Arr: array of Byte;
begin
  if (Key = nil) or (KeyByteLength <= 0) or (Z = nil) or (ZByteLength <= 0) then
    raise ECnSM9Exception.Create(SErrorMacParams);

  SetLength(Arr, KeyByteLength + ZByteLength);
  Move(Z^, Arr[0], ZByteLength);
  Move(Key^, Arr[ZByteLength], KeyByteLength);
  Result := SM3(@Arr[0], Length(Arr));
  SetLength(Arr, 0);
end;

{ TCnSM9EncryptionMasterKey }

constructor TCnSM9EncryptionMasterKey.Create;
begin
  inherited;
  FPrivateKey := TCnSM9EncryptionMasterPrivateKey.Create;
  FPublicKey := TCnSM9EncryptionMasterPublicKey.Create;
end;

destructor TCnSM9EncryptionMasterKey.Destroy;
begin
  FPublicKey.Free;
  FPrivateKey.Free;
  inherited;
end;

{ TCnSM9SignatureMasterKey }

constructor TCnSM9SignatureMasterKey.Create;
begin
  inherited;
  FPrivateKey := TCnSM9SignatureMasterPrivateKey.Create;
  FPublicKey := TCnSM9SignatureMasterPublicKey.Create;
end;

destructor TCnSM9SignatureMasterKey.Destroy;
begin
  FPublicKey.Free;
  FPrivateKey.Free;
  inherited;
end;

{ TCnFP2Point }

procedure TCnFP2Point.Assign(Source: TPersistent);
begin
  if Source is TCnFP2Point then
  begin
    FP2Copy(FX, (Source as TCnFP2Point).X);
    FP2Copy(FY, (Source as TCnFP2Point).Y);
  end
  else
    inherited;
end;

constructor TCnFP2Point.Create;
begin
  inherited;
  FX := TCnFP2.Create;
  FY := TCnFP2.Create;
end;

destructor TCnFP2Point.Destroy;
begin
  FY.Free;
  FX.Free;
  inherited;
end;

function TCnFP2Point.ToString: string;
begin
  Result := FP2PointToString(Self);
end;

{ TCnSM9 }

constructor TCnSM9.Create;
begin
  inherited Create(ctSM9Bn256v1);
  FGenerator2 := TCnFP2Point.Create;

  FGenerator2.X.SetHex(CN_SM9_G2_P2X0, CN_SM9_G2_P2X1);
  FGenerator2.Y.SetHex(CN_SM9_G2_P2Y0, CN_SM9_G2_P2Y1);
end;

destructor TCnSM9.Destroy;
begin
  FGenerator2.Free;
  inherited;
end;

{ TCnSM9Signature }

constructor TCnSM9Signature.Create;
begin
  inherited;
  FH := TCnBigNumber.Create;
  FS := TCnEccPoint.Create;
end;

destructor TCnSM9Signature.Destroy;
begin
  FS.Free;
  FH.Free;
  inherited;
end;

function TCnSM9Signature.ToString: string;
begin
  Result := FH.ToHex + CRLF + FS.ToHex;
end;

{ TCnSM9KeyEncapsulation }

constructor TCnSM9KeyEncapsulation.Create;
begin
  inherited;
  FCode := TCnSM9KeyEncapsulationCode.Create;
end;

destructor TCnSM9KeyEncapsulation.Destroy;
begin
  FCode.Free;
  inherited;
end;

function TCnSM9KeyEncapsulation.ToString: string;
begin
  Result := StrToHex(PAnsiChar(FKey), Length(FKey)) + CRLF + FCode.ToHex;
end;

{ TCnSM9KeyExchangeMasterKey }

constructor TCnSM9KeyExchangeMasterKey.Create;
begin
  FPrivateKey := TCnSM9KeyExchangeMasterPrivateKey.Create;
  FPublicKey := TCnSM9KeyExchangeMasterPublicKey.Create;
end;

destructor TCnSM9KeyExchangeMasterKey.Destroy;
begin
  FPublicKey.Free;
  FPrivateKey.Free;
  inherited;
end;

initialization
  FLocalBigNumberPool := TCnBigNumberPool.Create;
  FLocalFP2Pool := TCnFP2Pool.Create;
  FLocalFP4Pool := TCnFP4Pool.Create;
  FLocalFP12Pool := TCnFP12Pool.Create;
  FLocalFP2AffinePointPool := TCnFP2AffinePointPool.Create;

  InitSM9Consts;

finalization
  FLocalFP2AffinePointPool.Free;
  FLocalFP12Pool.Free;
  FLocalFP4Pool.Free;
  FLocalFP2Pool.Free;
  FLocalBigNumberPool.Free;

  FreeSM9Consts;

end.
