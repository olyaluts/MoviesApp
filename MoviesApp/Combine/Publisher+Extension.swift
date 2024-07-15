//
//  Publisher+Extension.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import Combine

// Similar behaviour like drive() in RXSwift
extension Publisher {
    func drive<S>(subscriber: S) -> AnyCancellable
        where S: Subscriber,
        S: Cancellable,
        Self.Failure == S.Failure,
        Self.Output == S.Input
    {
        receive(on: RunLoop.main).receive(subscriber: subscriber)
        return AnyCancellable.init {
            subscriber.cancel()
        }
    }
}

extension Publisher where Failure == Never {
    func drive(onNext: @escaping (Self.Output) -> Void) -> AnyCancellable {
        receive(on: RunLoop.main)
            .sink { value in
                onNext(value)
            }
    }

    /**
     Maps any output of the upstream publisher to Void

     NOTE: any output of the upstream publisher will be just skipped
     */
    func mapToVoid() -> Publishers.Map<Self, Void> {
        map { _ in () }
    }

    /**
     Maps any output of the upstream publisher to the given boolean value

     NOTE: any output of the upstream publisher will be just skipped
     */
    func map(to boolValue: Bool) -> Publishers.Map<Self, Bool> {
        map { _ in boolValue }
    }

    /**
     Publishes the integer value which is essentially the number of events published into the upstream publisher.

     NOTE: any output of the upstream publisher will be just skipped
     */
    func asCounter() -> Publishers.Scan<Self, Int> {
        scan(0) { partialResult, _ in partialResult + 1 }
    }

    /**
     Executes a given block on each element in the stream. Similar to the map function, but it doesn't intent to change the element in any way.
     Useful, to hook up into the stream and do any required actions based on the element value without modifying the element itself.

     - Parameters:
        - block: a closure which will be called on each element in a stream
     */
    func tap(_ block: @escaping (Self.Output) -> Void) -> Publishers.Map<Self, Self.Output> {
        map {
            block($0)
            return $0
        }
    }
}

// Error handling
extension Publisher {
    func replaceError(
        with output: Self.Output,
        errorHandler: RXErrorHandler? = nil,
        onErrorCaught: ((Error) -> Void)? = nil
    ) -> Publishers.Catch<Self, Just<Self.Output>> {
        self.catch { error in
            onErrorCaught?(error)
            errorHandler?.errorSubject.send(error)
            return Just(output)
        }
    }
}
