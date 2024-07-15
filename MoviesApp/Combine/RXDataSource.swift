//
//  RXDataSource.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import Combine

protocol RXDataSource: AnyObject {
    associatedtype Data
    func set(data: Data)
}

final class RXDataSourceSubscriber<DataSource>: Subscriber, Cancellable where DataSource: RXDataSource {
    typealias Input = DataSource.Data
    typealias Failure = Never

    private weak var dataSource: DataSource?
    private var subscription: Subscription?
    private let demand: Subscribers.Demand

    init(_ dataSource: DataSource, demand: Subscribers.Demand = .unlimited) {
        self.dataSource = dataSource
        self.demand = demand
    }

    func receive(subscription: Subscription) {
        self.subscription = subscription
        subscription.request(demand)
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        dataSource?.set(data: input)
        return demand == .unlimited ? .unlimited : .none
    }

    func receive(completion _: Subscribers.Completion<Never>) {
        dataSource = nil
    }

    func requestMore() {
        subscription?.request(demand)
    }

    func cancel() {
        subscription?.cancel()
        subscription = nil
    }
}

extension RXDataSource {
    var dataSubscriber: RXDataSourceSubscriber<Self> {
        RXDataSourceSubscriber(self)
    }
}

