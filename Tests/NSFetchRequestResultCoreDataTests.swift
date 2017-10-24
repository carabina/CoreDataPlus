// 
// CoreDataPlus
//
// Copyright © 2016-2017 Tinrobots.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import XCTest
import CoreData
@testable import CoreDataPlus

class NSFetchRequestResultCoreDataTests: XCTestCase {

  func testDeleteAll() {
    let stack = CoreDataStack()!
    let context = stack.mainContext

    // Given
    context.fillWithSampleData()
    // When
    SportCar.deleteAll(in: context, where: NSPredicate(format: "%K == %@", #keyPath(SportCar.numberPlate), "302"))
    // Then
    XCTAssertTrue(SportCar.fetch(in: context).filter { $0.numberPlate == "302" }.isEmpty)
    XCTAssertTrue(ExpensiveSportCar.fetch(in: context).filter { $0.numberPlate == "302" }.isEmpty)

    // When
    ExpensiveSportCar.deleteAll(in: context, where: NSPredicate(format: "%K == %@", #keyPath(SportCar.numberPlate), "301"))
    // Then
    XCTAssertTrue(SportCar.fetch(in: context).filter { $0.numberPlate == "301" }.isEmpty)
    XCTAssertTrue(ExpensiveSportCar.fetch(in: context).filter { $0.numberPlate == "301" }.isEmpty)

    // When
    SportCar.deleteAll(in: context, where: NSPredicate(value: true))
    // Then
    XCTAssertTrue(SportCar.fetch(in: context).isEmpty)
    XCTAssertTrue(ExpensiveSportCar.fetch(in: context).isEmpty)
    XCTAssertTrue(!Car.fetch(in: context).isEmpty)

    // When
    Car.deleteAll(in: context)
    // Then
    XCTAssertTrue(Car.fetch(in: context).isEmpty)

  }

  func testDeleteAllExcludingExceptions() {
    let stack = CoreDataStack()!
    let context = stack.mainContext
    // Given
    context.fillWithSampleData()

    let optonalCar = Car.fetch(in: context).filter { $0.numberPlate == "5" }.first
    let optionalPerson = Person.fetch(in: context).filter { $0.firstName == "Theodora" && $0.lastName == "Stone" }.first
    let persons = Person.fetch(in: context).filter { $0.lastName == "Moreton" }

    guard
      let car = optonalCar,
      let person = optionalPerson,
      !persons.isEmpty
      else {
        XCTAssertNotNil(optonalCar)
        XCTAssertNotNil(optionalPerson)
        XCTAssertFalse(persons.isEmpty)
        return
    }

    Car.deleteAll(in: context, except: [car])
    XCTAssertNotNil(Car.fetch(in: context).filter { $0.numberPlate == "5" }.first)
    XCTAssertTrue(Car.fetch(in: context).filter { $0.numberPlate != "5" }.isEmpty)

    var exceptions = persons
    exceptions.append(person)
    Person.deleteAll(in: context, except: exceptions)
    XCTAssertFalse(Person.fetch(in: context).filter { ($0.firstName == "Theodora" && $0.lastName == "Stone") || ($0.lastName == "Moreton") }.isEmpty)

    Person.deleteAll(in: context, except: [])
    XCTAssertTrue(Person.fetch(in: context).isEmpty)

    // test with sport and expensivesportcar subentities
    // test removing subentities

  }

}
