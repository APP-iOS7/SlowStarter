
Config: 구성요소로서 API 키 값, 환경에 따른 주소 등 입력
 - API: API Key값은 .xconfig 파일로 작성
 - Environment: 플랫폼 환경, 버전에 따라 필요한 구성 설정 정보를 담은 폴더

Presentation: ViewController, View, ViewModel, Style config 와 같은 뷰를 나타내는 파일이 담긴 폴더
 - CommonView: 공통으로 사용되는 뷰 폴더
 - Coordinators: 코디네이터 패턴으로서 Navigation 역할을 하는 파일이 담긴 폴더
 - Scenes: ViewController, View, ViewModel이 담긴 폴더로 Scene마다 폴더를 만들어 그 안에서 작업
 - Styles: 폰트, 패딩, 컬러 등등의 UI에서 사용되는 Config 폴더

Data: 데이터, 네트워크 통신과 같은 작업을 하는 폴더
 - Network: API 세부 기능을 작성한 파일의 폴더
 - Persistence: DB 세부 기능을 작성한 파일의 폴더
 - Respository: Network, Persistence 함수를 이용해서 원하는 기능을 정의한 파일의 폴더로 Presentation에서 실질적으로 사용하는 파일을 담고 있음.

Domain: 최하위 계층으로 어떤 것에도 의존하지 않는 파일들을 담은 폴더
 - Extension: 모디파이어와 같은 것의 extension을 작성한 파일의 폴더로 ViewController나 ViewModel과 같은 extension파일은 작성하지 않음.(의존이 없어야하는 extention)
 - Models: entity Model을 담은 폴더
 - Protocols: 프로토콜을 담은 폴더
   - Repository: "Data"폴더의 Respository에 사용할 프로토콜을 작성한 파일의 폴더
   - UseCase: Repository를 제외한 모든 프로토콜을 작성한 파일의 폴더로 필요에 의해 분리할 수 있음.
 - ValueObject: Email, Password와 같이 형식이 필요한 것을 확인할 수 있는 구조체나 그와 비슷한 모든 것이 담기는 폴더로 불변성을 가지고 어떤 것에도 의존하지 않는 로직
