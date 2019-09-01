import XCTest
import swift_net
@testable import swinf

final class swinfTests: XCTestCase {
    let provider: Provider = Provider()
    
    func testCreateDatabase() {
        let expectation = XCTestExpectation(description: "test create database")
        let url = URL(string: "http://localhost:8086")!
        provider.request(target: InfluxAPI.createDatabase(url: url, name: "test2")) { (result) in
            switch result {
            case .success(let response, let data):
                print(String(data: data, encoding: .utf8)!)
                print("success")
                XCTAssertEqual(response.statusCode, 200)
            case .failure:
                print("error")
                XCTFail()
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testWriteToDatabase() {
        let expectation = XCTestExpectation(description: "test write to database")
        let url = URL(string: "http://localhost:8086")!
        provider.request(target: InfluxAPI.write(
            url: url,
            dbName: "test2",
            measure: "cpu_load_short,host=server01,region=us-west value=0.2")) { (result) in
            switch result {
            case .success(let response, let data):
                print(String(data: data, encoding: .utf8)!)
                print(response)
                print("success")
                XCTAssertEqual(response.statusCode, 204)
            case .failure:
                XCTFail()
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testQueryDatabase() {
        let expectation = XCTestExpectation(description: "test query database")
        let url = URL(string: "http://localhost:8086")!
        provider.request(target: InfluxAPI.query(url: url, dbName: "test2", q: "SELECT value FROM cpu_load_short")) { (result) in
                switch result {
                case .success(let response, let data):
                    do {
                        let influxResult = try JSONDecoder().decode(InfluxResult.self, from: data)
                        XCTAssertEqual(response.statusCode, 200)
                        print(influxResult)
                    } catch {
                        fatalError()
                    }

                case .failure:
                    XCTFail()
                }
                
                expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }

    static var allTests = [
        ("createDatabase", testCreateDatabase),
        ("writeDatabase", testWriteToDatabase),
        ("queryDatabase", testQueryDatabase)
    ]
}
