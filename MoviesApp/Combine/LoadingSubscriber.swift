//
//  LoadingSubscriber.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import Combine

protocol LoadingProtocol: AnyObject {
    func showLoading()
    func hideLoading()
}

public final class LoadingSubscriber: Subscriber, Cancellable {
    public typealias Input = Bool
    public typealias Failure = Never

    private weak var loadingView: LoadingProtocol?
    private var subscription: Subscription?

    init(_ loadingView: LoadingProtocol) {
        self.loadingView = loadingView
    }

    public func receive(subscription: Subscription) {
        self.subscription = subscription
        subscription.request(.unlimited)
    }

    public func receive(_ input: Bool) -> Subscribers.Demand {
        input ? loadingView?.showLoading() : loadingView?.hideLoading()
        return .unlimited
    }

    public func receive(completion _: Subscribers.Completion<Never>) {
        loadingView = nil
    }

    public func cancel() {
        subscription?.cancel()
        subscription = nil
    }
}

extension LoadingProtocol {
    var loading: LoadingSubscriber {
        LoadingSubscriber(self)
    }
}

