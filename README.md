# EfcRickMorty
SwiftUI / Combine / MVVM / Testing


1. [Descripción](#descripcion)
2. [Estructura](#estructura)
3. [NETWORK](#network)
4. [EndPoint](#endpoint)
5. [LiveMock](#livemock)
6. [Extension Color](#extensioncolor)
7. [Style](#style)
8. [Views](#views)
9. [ViewModifier](#viewmodifier)
10. [Testing](#testing)
- [TestListFeature.swift](#testlistfeature-swift)

## Descripción

**Este proyecto contiene dos features LIST and DETAIL.**

Este el flujo de navegacion desde la VIEW  a la llamada a la API

 VIEW -> VIEWMODEL -> USE CASE -> REPOSITORY 

Y este el flujo de navegación de la API a la VIEW.

 REPOSITORY -> USE CASE -> MAPPER -> VIEWMODEL -> VIEW 

Por el mismo camino hasta la VISTA inicial pasando por un MAPPER que modifica el valor de la respuesta a un formato ideal para el VIEWMODEL.

```swift

SwiftUI / Combine / MVMV 

View / Domain / Data / Repository

Mocks / Mapper / DTO 

Este proyecto contiene una arquitectura fácil de leer, mantener y testear.

Para testear se puede inyectar los servicios mocks (json) en lugar del servicio live (API).

```


## Estructura


**El propósito es llamar a : rickandmortyapi.com/api/ y mostrar la lista de personajes en la VIEW.**

| Carpeta | SubCarpeta  | Fichero | Descripción |
|--------------|--------------|--------------|--------------|
| List | | | |
|  | View | |  |
|  | | ListView  | Views components |
|  | | ListModel | Data para alimentar la vista |
|  | Domain | |  |
|  | | ListCaseUse  | Define metodo: getList: (String) -> AnyPublisher<ListModel, NetworkError> |
|  | | ListCaseLive | Implementa getList. Comunica con el Repository Live |
|  | | ListCaseMock | Implementa getList. Comunica con el  Repository Mock |
|  | Data | |  |
|  | | ListRepository  | Define methodo: getList: () -> AnyPublisher<ListDTO, NetworkError> |
|  | | ListRepositoryLive | LLama  -> CombineManager.shared.getData(endpoint: EndPoint.character(.all), type: ListDTO.self (Si la búsqueda contiene texto llama al endPoint Filter) |
|  | | ListRepositoryMock | Llama -> try! JSONDecoder().decode(ListDTO.self, from: jsonListDTO)  (Return MOCK ListDTO) |


## NETWORK


| Carpeta | SubCarpeta  | Fichero | Descripción |
|--------------|--------------|--------------|--------------|
| Network (Folder) | | | |
|  | URLSessionManager.swift|  | Metodo: getData<T: Decodable>(endpoint: EndPointProtocol, type: T.Type) Call API |
|  | URLRequestMethod.swift|  | Enum para utilizar en EndPoint e indicar si es GET, POST, ... |
|  | EndPoint.swift|  | Define endPoint con sus propiedades |
|  | Configuration| | |
|  | | Config | Estructura para la ConfigurationNet con propiedad baseUrl rickandmortyapi.com/api|
|  | | Configuration| Usa la Config struct. Este alimenta la propiedad baseURL en el EndPoint |
|  | Protocols| | |
|  | | EndPointProtocol | Define interface headers, method, urlString, parameters que el EndPoint debe de implementar |
|  | Error | | |
|  | | NetWorkError | Extend Error para capturar errorType |
|  | Mapper | | |
|  | | Mapper | Define método para mapper valores desde DTO al Model |




## EndPoint


En un enum gestiono la creación de los endPoints utilizados para llamar a la API.


```swift
enum EndPointType {
    case all
    case one(Int)
    case multiple([Int])
    case filter(String)
    case page(String)
    
    var route: String {
        switch self {
        case .all:
            return ""
        case .one (let id):
            return "/\(id)"
        case .multiple (let ids):
            return "/\(ids)"
        case .filter (let filter):
            return "/?name=\(filter)"
        case .page (let page):
            return "/?page=\(page)"
        }
    }
}

```

```swift
enum EndPoint: EndPointProtocol  {
    
    case character(EndPointType)
    case location(EndPointType)
    case episode(EndPointType)
    
    var headers: [String : String] {
        var headers: [String: String] = [:]
        headers["Accept"] = "application/json"
        headers["Accept-Language"] = "es"
        return headers
    }
    
    private var baseURL: String {
        return ConfigurationNet.shared.data.baseUrl
    }
    
    var urlString: String {
        switch self {
        case .character(let type), .location(let type), .episode(let type):
            return "\(baseURL)\(endPointType)\(type.route)"
        }
    }
    
    var parameters: [String : Any] {
        var params: [String: Any] = [:]
        switch self {
        case .character(.all):
               // params = ["page": 1] Example for use this property
               params = [:]
            default:
                break
        }
        
        return params
    }
    
    var method: String {
        switch self {
        case .character( _), .location( _), .episode( _):
            return URLRequestMethod.get.rawValue
        }
    }
    
    var endPointType: String {
        switch self {
        case .character:
            return "character"
        case .location:
            return "location"
        case .episode:
            return "episode"
        }
    }

}

```

# Live&Mock  


En el ViewModel se inyecta el caso de uso .live para llamar a la API.

En el ViewModel se inyecta el caso de uso .mock para utilizar los jsons mocks.

#### ListViewModel.swift

```swift
final class ListViewModel: ObservableObject {
    
    @Published var viewModelState: ViewModelState = ViewModelState.loadingView
    @Published var alertItem: AlertItem?
    @Published var searchText: String = ""
    @Published var clearSearchText: Bool = false
    
    private var listUseCase: ListUseCase
    private var task: Cancellable?
    private var cancellables = Set<AnyCancellable>()
  
    var characters: ListModel? = nil
    var charactersFiltered: ListModel? = nil

    init(listUseCase: ListUseCase = .live) { // CAMBIAR POR .mock para utilizar datos mock definidos en formato json
        self.listUseCase = listUseCase
        addSubscriberForComponents()
        getList()
    }

    ...

```

## Extension&Color


De esta manera defino los colores para aplicar a los componentes de la vista.

```swift
extension Color {
    static let themeOption = ColorThemeOption()
    static let themeCardDetail = ColorThemeCardDetail()
    static let themeItem = ColorThemeItem()
}

struct ColorThemeOption {
    let optionOne = Color("OptionOne")
    let optionTwo = Color("OptionTwo")
    let optionThree = Color("OptionThree")
    
    let unSelectedOption = Color("UnSelectedOption")
}

struct ColorThemeCardDetail {
    let header = Color("HeaderCard")
    let body = Color("BodyCard")
}

struct ColorThemeItem {
    let header = Color("HeaderItem")
    let body = Color("BodyItem")
}
```


## Style


Definido style para reutilizar.

```swift

struct CustomTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .fontWeight(.heavy)
    }
}

struct CustomModifierCardDetailItem: ViewModifier {
    
    let colorBack: Color?
    let heightContent: CGFloat?
    
    init(colorBack: Color = Color.themeItem.header, heightContent: CGFloat = CGFloat(80) ) {
        self.colorBack = colorBack
        self.heightContent = heightContent
    }
    
    func body(content: Content) -> some View {
        content
            .frame(height: heightContent)
            .frame(maxWidth: .infinity)
            .background(colorBack)
            .foregroundColor(.white)
            .clipShape(RoundedCorner(radius: 30, corners: [.bottomLeft, .topRight]))
            .padding(.leading, 0)
            .padding(.trailing, 0)
        
    }
}

```

## Views


Esta es la pantalla que muestra el listado inicial y permite una búsqueda por nombre.


![Pantalla ListView](/pantallainicial400.png)





Búsqueda en la pantalla (ListView)
---

Introducir por lo menos tres carácteres y pulsar en la lupa para la búsqueda.


![Pantalla ListView](/pantallabusqueda.png)


Paginador en la pantalla
---

La primera petición obtiene de la peticiòn el info (pages) el número de páginas para generar botonera.

![Pantalla ListView](/pantallapaginador.png)

Página 20 seleccionada.


![Pantalla ListView](/pagina20.png)



Captura pantalla (Custom component)
---

Esta captura de pantalla muestra el componente customizado ItemCharacter.

Es un diseño que he visto y he implementado el código desde cero.


![Componente creado](/ItemListRickMorty.png)

Enums para uso de Emoji  
---

Utilización de enums para mostrar Emoji en lujar de texto

```Swift
enum StatusCharacter {
    case alive
    case dead
    case unknown
    
    var iconDescription: String? {
        switch self {
        case .alive: return "🕺"
        case .dead: return "💀"
        case .unknown: return "?"
        }
    }
}
```

```Swift
enum GenderCharacter {
    case female
    case male
    case unknown
    
    var iconDescription: String? {
        switch self {
        case .female: return "👩‍⚖️"
        case .male: return "🤵‍♂️"
        case .unknown: return "?"
        }
    }
}
```

Lo aplico en la pantalla de detalle.

![Pantalla ListView](/pantalladetalle.png)

![Pantalla ListView](/statusdead.png)

![Pantalla ListView](/genderfemale.png)


## ViewModifier
---

Estaba aplicando un estilo tanto a CardDetail como a ItemCharacter. 

He creado un Modifier con al que se puede pasar un color de fondo a aplicar. 

De esta manera he reducido código redundante.

```Swift

struct CustomTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .fontWeight(.heavy)
    }
}

struct CustomModifierCardDetailItem: ViewModifier {
    
    let colorBack: Color?
    let heightContent: CGFloat?
    
    init(colorBack: Color = Color.themeItem.header, heightContent: CGFloat = CGFloat(80) ) {
        self.colorBack = colorBack
        self.heightContent = heightContent
    }
    
    func body(content: Content) -> some View {
        content
            .frame(height: heightContent)
            .frame(maxWidth: .infinity)
            .background(colorBack)
            .foregroundColor(.white)
            .clipShape(RoundedCorner(radius: 30, corners: [.bottomLeft, .topRight]))
            .padding(.leading, 0)
            .padding(.trailing, 0)
        
    }
}

```


## Testing

### TestListFeature.swift

| Fichero | Descripción de los tests |
|---------|-------------------------|
| `TestListFeature.swift` | - Comprueba que el primer personaje devuelto por la API tiene el `id = 1`.<br>- Comprueba la paginación de la página 3. |

```Swift

final class TestListFeature: XCTestCase {

    var sut: CombineManager! // System Under Test: El objeto que vamos a testear
    
    override func setUpWithError() throws {  // Se ejectua antes de cada test
        super.setUp()
        sut = CombineManager.shared
    }

    override func tearDownWithError() throws { // Se ejecuta después de cada test
        sut = nil
        super.tearDown()
    }

    // Comprueba que el primer personaje devuelto por la API tiene el id = 1
    func testGetList_idFirst_equal_one() throws {

        let expectation = self.expectation(description: "Espera el resultado de la API")
        
        let cancellabe = sut.getData(endpoint: EndPoint.character(.all), type: ListDTO.self).sink (
            receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Error: \(error.localizedDescription)")
                    }
                }, receiveValue: { response in
                    XCTAssertEqual(response.results[0].id, 1)
                })
            // Espera máxima 10 segundos para que se cumpla la expectativa
            waitForExpectations(timeout: 10, handler: nil)
            cancellabe.cancel()
    
    }

    // Comprueba la paginación de la página 3
    func testGetList_pageNumberThree_previousTwo_nextFour() throws {

        // URLs esperadas para la paginación
        let previousUrl = "https://rickandmortyapi.com/api/character/?page=2"
        let nextUrl = "https://rickandmortyapi.com/api/character/?page=4"
        // Crea espectativas para la llamada asíncron
        let expectation = self.expectation(description: "Espera el resultado de la API")
        // Llamada a la API para la página 3
        let cancellabe = sut.getData(endpoint: EndPoint.character(.page("3")), type: ListDTO.self).sink (
            receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Error: \(error.localizedDescription)")
                    }
                }, receiveValue: { response in
                    XCTAssertEqual(response.info.prev, previousUrl)
                    XCTAssertEqual(response.info.next, nextUrl)
                })
            
            waitForExpectations(timeout: 10, handler: nil)
            cancellabe.cancel()
        
    }

}

```

| Fichero | Descripción de los tests |
|---------|-------------------------|
| `URLProtocolStub.swift` | - Devuelve la request "canónica", es decir, la verión estándard de la petición.<br>- Simula la respuesta devolviendo datos, cabeceras y código HTTP o un error si está configurado. |



```Swift


/// `URLProtocolStub` es un `URLProtocol` personalizado para interceptar peticiones de red
/// en tests unitarios. Permite simular respuestas HTTP con datos, errores o retrasos.
final class URLProtocolStub: URLProtocol {
    
    /// Datos a devolver en la respuesta simulada.
    static var responseData: Data?
    
    /// Código de estado HTTP de la respuesta (por defecto 200).
    static var statusCode: Int = 200
    
    /// Cabeceras HTTP de la respuesta simulada.
    static var headers: [String: String] = [:]
    
    /// Contador de peticiones interceptadas (útil para validar en tests).
    static var requestCount: Int = 0
    
    /// Error a devolver en lugar de una respuesta correcta (simula fallos de red).
    static var error: Error?
    
    /// Tiempo de espera artificial antes de responder (simula latencia de red).
    static var responseDelay: TimeInterval = 0

    // MARK: - URLProtocol Overrides
    
    /// Determina si este protocolo puede manejar una petición dada.
    ///
    /// - Parameter request: La `URLRequest` que se va a evaluar.
    /// - Returns: `true` para indicar que se interceptan todas las peticiones.
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    /// Devuelve la request "canónica", es decir, la versión estándar de la petición.
    ///
    /// - Parameter request: La `URLRequest` original.
    /// - Returns: La misma request sin modificaciones.
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    /// Inicia la carga de la petición interceptada.
    /// Simula la respuesta devolviendo datos, cabeceras y código HTTP o un error si está configurado.
    ///
    /// - Comportamiento:
    ///   1. Valida la URL de la request.
    ///   2. Incrementa el contador de peticiones.
    ///   3. Si se configuró un error, lo devuelve al cliente.
    ///   4. Si no, construye un `HTTPURLResponse` con `statusCode` y `headers`.
    ///   5. Devuelve los datos (`responseData` o vacío).
    ///   6. Marca la carga como finalizada.
    ///   7. Si hay `responseDelay`, espera ese tiempo antes de responder.
    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        URLProtocolStub.requestCount += 1

        let respond: () -> Void = { [weak self] in
            guard let self = self else { return }
            if let error = URLProtocolStub.error {
                self.client?.urlProtocol(self, didFailWithError: error)
                return
            }
            let response = HTTPURLResponse(url: url,
                                           statusCode: URLProtocolStub.statusCode,
                                           httpVersion: nil,
                                           headerFields: URLProtocolStub.headers)!
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = URLProtocolStub.responseData {
                self.client?.urlProtocol(self, didLoad: data)
            } else {
                self.client?.urlProtocol(self, didLoad: Data())
            }
            self.client?.urlProtocolDidFinishLoading(self)
        }

        if URLProtocolStub.responseDelay > 0 {
            DispatchQueue.global().asyncAfter(deadline: .now() + URLProtocolStub.responseDelay, execute: respond)
        } else {
            respond()
        }
    }

    /// Detiene la carga de la petición.
    /// - Nota: En este stub no es necesario implementar lógica de cancelación.
    override func stopLoading() {}
}


```

| Fichero | Descripción de los tests |
|---------|-------------------------|
| `TestListModelMapping.swift` | - Pruebas unitarias para verificar la correcta codificación decodificación y mapeo del DTO. |



```Swift

/// `TestListModelMapping` contiene pruebas unitarias para verificar
/// la correcta decodificación y mapeo del DTO (`ListDTO`) hacia el modelo de dominio (`ListModel`).
final class TestListModelMapping: XCTestCase {
    
    /// Verifica que un `ListDTO` puede:
    /// 1. Ser decodificado correctamente desde JSON.
    /// 2. Mapearse adecuadamente al modelo de dominio `ListModel`.
    ///
    /// - Throws: Lanza error si la decodificación del JSON falla.
    ///
    /// - Comportamiento probado:
    ///   - El número de páginas (`numberPages`) se asigna correctamente.
    ///   - La colección `data` contiene el número esperado de elementos.
    ///   - El primer elemento tiene los valores esperados (`id` y `name`).
    ///   - El último elemento tiene el `id` esperado.
    func test_listDTO_decodes_and_maps_to_ListModel() throws {
        // 1. Decodifica el DTO desde un JSON simulado
        let dto = try JSONDecoder().decode(ListDTO.self, from: jsonListDTO)

        // 2. Mapea el DTO a tu modelo de dominio
        let model = ListModel()
        model.fromDto(dto: dto)

        // 3. Validaciones (Asserts)
        XCTAssertEqual(model.numberPages, 42, "El número de páginas debe ser 42")
        XCTAssertEqual(model.data.count, 2, "El modelo debe contener 2 personajes")
        XCTAssertEqual(model.data.first?.id, 1, "El primer personaje debe tener id = 1")
        XCTAssertEqual(model.data.first?.name, "Rick Sanchez", "El primer personaje debe ser Rick Sanchez")
        XCTAssertEqual(model.data.last?.id, 2, "El último personaje debe tener id = 2")
    }
}


```



| Fichero | Descripción de los tests |
|---------|-------------------------|
| `TestCombineManager.swift` | - Contiene pruebas unitarias para verificar el comportamiento de CombineManager en operaciones de red simuladas. |



```Swift

/// `TestCombineManager` contiene pruebas unitarias para verificar
/// el comportamiento del `CombineManager` en operaciones de red simuladas.
///
/// Se utiliza `URLProtocolStub` para interceptar peticiones de red y devolver
/// respuestas controladas sin necesidad de un servidor real.
final class TestCombineManager: XCTestCase {
    
    /// Conjunto de suscripciones de Combine que deben liberarse
    /// al finalizar cada test.
    var cancellables = Set<AnyCancellable>()

    // MARK: - Ciclo de vida del test
    
    /// Configura el entorno de pruebas antes de cada ejecución.
    /// - Registra `URLProtocolStub` para que intercepte todas las peticiones de red.
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    /// Limpia el entorno después de cada prueba.
    /// - Elimina el registro del stub.
    /// - Vacía el conjunto de suscripciones.
    override func tearDown() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - Tests
    
    /// Verifica que cuando `CombineManager.getData` recibe una respuesta HTTP exitosa (200)
    /// con un JSON válido (`jsonListDTO`), se decodifica correctamente a `ListDTO`.
    ///
    /// - Pasos probados:
    ///   1. Se configura el `URLProtocolStub` con `statusCode = 200` y datos válidos.
    ///   2. Se hace la llamada a `getData`.
    ///   3. Se espera que la decodificación produzca un `ListDTO` válido.
    ///   4. Se valida que el primer elemento tenga `id = 1`.
    func test_getData_success_decodes_ListDTO() {
        // Prepara respuesta simulada
        URLProtocolStub.statusCode = 200
        URLProtocolStub.responseData = jsonListDTO

        let exp = expectation(description: "decode success")
        
        CombineManager.shared
            .getData(endpoint: EndPoint.character(.all), type: ListDTO.self)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let err) = completion {
                        XCTFail("Unexpected error: \(err)")
                    }
                },
                receiveValue: { dto in
                    XCTAssertEqual(dto.results.first?.id, 1, "El primer resultado debe tener id = 1")
                    exp.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [exp], timeout: 2)
    }

    /// Verifica que cuando `CombineManager.getData` recibe una respuesta HTTP con error (404),
    /// se emite un `NetworkError` y no un valor decodificado.
    ///
    /// - Pasos probados:
    ///   1. Se configura el `URLProtocolStub` con `statusCode = 404` y datos vacíos.
    ///   2. Se hace la llamada a `getData`.
    ///   3. Se espera que el `sink` reciba un `.failure`.
    ///   4. Se valida que **no** se reciba ningún valor decodificado.
    func test_getData_http_error_maps_to_NetworkError() {
        URLProtocolStub.statusCode = 404
        URLProtocolStub.responseData = Data()

        let exp = expectation(description: "http error")
        
        CombineManager.shared
            .getData(endpoint: EndPoint.character(.all), type: ListDTO.self)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(_) = completion {
                        exp.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("La llamada no debería completarse con éxito en caso de error HTTP")
                }
            )
            .store(in: &cancellables)

        wait(for: [exp], timeout: 2)
    }
}



```



