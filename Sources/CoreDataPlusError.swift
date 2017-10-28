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

import Foundation
import CoreData

/// **CoreDataPlus**
///
/// `CoreDataPlusError` is the error type returned by CoreDataPlus. It encompasses a few different types of errors, each with
/// their own associated reasons.
///
/// - contextOperationFailed: Returned when a NSManagedObjectContext error occurs.
/// - configurationFailed: Returned when a configuration error occurs.
public enum CoreDataPlusError: Error {

    case contextOperationFailed(reason: ContextOperationFailureReason)
    case configurationFailed(reason: ConfigurationFailureReason)

    /// **CoreDataPlus**
    ///
    /// The `Error` returned by a system framework associated with a configuration or a context operation error.
    public var underlyingError: Error? {
        switch self {
        case .configurationFailed(let reason):
            return reason.underlyingError
        case .contextOperationFailed(let reason):
            return reason.underlyingError
        }
    }

    /// **CoreDataPlus**
    ///
    /// The underlying reason the configuration error occurred.
    ///
    /// - entityNotFound: The NSEntity is not found.
    /// - persistentStoreCoordinator: The NSPersistentStoreCoordinator is missing.
    public enum ConfigurationFailureReason {
        
        case persistentStoreCoordinatorNotFound(context: NSManagedObjectContext)

        /// **CoreDataPlus**
        ///
        /// The `Error` returned by a system framework associated with configuration failure error.
        public var underlyingError: Error? { return nil }
    }

    /// **CoreDataPlus**
    ///
    /// The underlying reason the NSManagedObjectContext error occurred.
    ///
    /// - executionFailed: A context executions failed.
    /// - fetchCountNotFound: A count fetch operation failed.
    /// - fetchExpectingOneObjectFailed: A fetch operation expecting only one object failed.
    /// - fetchFailed: A fetch operation failed with an underlying system error.
    /// - saveFailed: A save oepration failed with an underlying system error
    public enum ContextOperationFailureReason {
        case executionFailed(error: Error)
        case fetchCountNotFound
        case fetchExpectingOneObjectFailed
        case fetchFailed(error: Error)
        case saveFailed(error: Error)

        /// **CoreDataPlus**
        ///
        /// The `Error` returned by a system framework associated with a context operation failure error.
        public var underlyingError: Error? {
            switch self {
            case .fetchFailed(let error), .saveFailed(let error):
                return error
            default:
                return nil
            }
        }

    }

}

extension CoreDataPlusError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .contextOperationFailed(let reason):
            return reason.localizedDescription
        case .configurationFailed(let reason):
            return reason.localizedDescription
        }
    }

}

extension CoreDataPlusError.ContextOperationFailureReason: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .executionFailed(let error):
            return "\(error.localizedDescription)"
            
        case .fetchCountNotFound:
            return "The fetch count responded with NSNotFound."

        case .fetchExpectingOneObjectFailed:
            return "Returned multiple objects, expected max 1."

        case .fetchFailed(let error):
            return "The fetch could not be completed because of error:\n\(error.localizedDescription)"

        case .saveFailed(let error):
            return "The save operation could not be completed because of error:\n\(error.localizedDescription)"

        }
    }

}

extension CoreDataPlusError.ConfigurationFailureReason: LocalizedError {

    public var errorDescription: String? {
        switch self {

        case .persistentStoreCoordinatorNotFound(let context):
            return "\(context.description) doesn't have a NSPersistentStoreCoordinator."
        }

    }
}
