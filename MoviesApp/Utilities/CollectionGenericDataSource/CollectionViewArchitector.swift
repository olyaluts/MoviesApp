//
//  CollectionViewArchitector.swift
//  MoviesApp
//
//  Created by Olya Lutsyk on 14.07.2024.
//

import Foundation
import UIKit

typealias ArchitectorSectionID = String
typealias ArchitectorCellProviderID = String

protocol CollectionViewArchitector: AnyObject {
    func resetDataSource()
    func reload(animated: Bool, scrollTo item: ArchitectorCellProviderID?)
    func reload()
    func refresh(items: [ArchitectorCellProviderID], animated: Bool)
    func scrollToIndex(index: IndexPath)
}

final class CollectionViewArchitectorImpl: NSObject, CollectionViewArchitector {
    weak var dataSource: CollectionViewArchitectorDataSource? {
        didSet {
            resetDataSource()
        }
    }
    
    weak var scrollViewDelegate: UIScrollViewDelegate?
    
    // MARK: Private properties
    
    private var diffableDataSource: UICollectionViewDiffableDataSource<ArchitectorSectionID, ArchitectorCellProviderID>?
    private let collectionView: UICollectionView
    private lazy var registeredIdentifiers: Set<String> = []
    
    private var sections: [CollectionViewSection] {
        dataSource?.sections ?? []
    }
    
    private var emptyView: UIView? {
        dataSource?.emptyView
    }
    
    // MARK: Init
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        collectionView.delegate = self
    }
    
    // MARK: Internal methods
    
    func reload() {
        let snapshot = getSnapshot()
        // Workaround to setup snapshot and then reload it with animation.
        // Setting up with animation for first time breaks horizontal scroll.
        guard !snapshot.itemIdentifiers.isEmpty else { showEmptyView(); return }
        emptyView?.removeFromSuperview()
        DispatchQueue.main.async {
            self.diffableDataSource?.apply(snapshot)
            self.diffableDataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
    
    func reload(animated _: Bool, scrollTo item: ArchitectorCellProviderID?) {
        let snapshot = getSnapshot()
        diffableDataSource?.apply(snapshot, animatingDifferences: true, completion: { [weak self] in
            if let itemToScroll = item, let indexPath = snapshot.indexPath(for: itemToScroll) {
                self?.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            }
        })
    }
    
    func refresh(items: [ArchitectorCellProviderID], animated: Bool) {
        guard let diffableDataSource = diffableDataSource else {
            return
        }
        var snapshot = diffableDataSource.snapshot()
        snapshot.reloadItems(items)
        diffableDataSource.apply(snapshot, animatingDifferences: animated, completion: nil)
    }
    
    func reconfigureItems(items: [ArchitectorCellProviderID]) {
        guard let diffableDataSource = diffableDataSource else {
            return
        }
        var snapshot = diffableDataSource.snapshot()
        if #available(iOS 15.0, *) {
            snapshot.reconfigureItems(items)
        } else {
            // Fallback for iOS 13
            items.forEach { item in
                if let indexPath = snapshot.indexPath(for: item) {
                    let sectionIdentifier = snapshot.sectionIdentifiers[indexPath.section]
                    snapshot.deleteItems([item])
                    snapshot.appendItems([item], toSection: sectionIdentifier)
                }
            }
        }
        diffableDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    func scrollToIndex(index: IndexPath) {
        if collectionView.numberOfSections > 0 {
            collectionView.scrollToItem(at: index, at: .top, animated: true)
        }
    }
    
    // MARK: Private methods
    
    func showEmptyView() {
        guard emptyView?.superview == nil else {
            return
        }
        guard let emptyView = emptyView else { return }
        emptyView.frame = collectionView.bounds
        collectionView.addSubview(emptyView)
    }
    
    private func registerCells() {
        sections.flatMap(\.cellContexts).forEach { context in
            if !registeredIdentifiers.contains(context.cellIdentifier) {
                context.registerCell(in: collectionView)
                registeredIdentifiers.insert(context.cellIdentifier)
            }
        }
    }
    
    private func registerReusableViews() {
        sections.flatMap(\.supplementaryViewContexts.values).forEach { context in
            if !registeredIdentifiers.contains(context.kind) {
                context.registerReusableView(in: collectionView)
                registeredIdentifiers.insert(context.kind)
            }
        }
    }
    
    func resetDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource<ArchitectorSectionID, ArchitectorCellProviderID>(collectionView: collectionView) { [weak self]
            collectionView, indexPath, _ -> UICollectionViewCell? in
            guard let strongSelf = self else { return nil }
            let cellProvider = strongSelf.sections[indexPath.section].cellContexts[indexPath.row]
            return cellProvider.dequeueAndConfigure(in: collectionView, at: indexPath)
        }
        
        diffableDataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard let strongSelf = self else { return nil }
            let viewProvider = strongSelf.sections[indexPath.section].supplementaryViewContexts[kind]
            return viewProvider?.dequeueAndConfigure(in: collectionView, at: indexPath)
        }
        
        collectionView.dataSource = diffableDataSource
    }
    
    private func getSnapshot() -> NSDiffableDataSourceSnapshot<ArchitectorSectionID, ArchitectorCellProviderID> {
        registerReusableViews()
        registerCells()
        var snapshot = NSDiffableDataSourceSnapshot<ArchitectorSectionID, ArchitectorCellProviderID>()
        snapshot.appendSections(sections.map(\.id))
        sections.forEach { section in
            snapshot.appendItems(section.cellContexts.map(\.id), toSection: section.id)
        }
        return snapshot
    }
}

extension CollectionViewArchitectorImpl: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellProvider = sections[indexPath.section].cellContexts[indexPath.row]
        cellProvider.didSelectHandler?()
    }
    
    func collectionView(_: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cellProvider = sections[indexPath.section].cellContexts[indexPath.row]
        cellProvider.willDisplayHandler?(cell)
    }
    
    func collectionView(_: UICollectionView, didEndDisplaying _: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard sections.count > indexPath.section,
              sections[indexPath.section].cellContexts.count > indexPath.row
        else {
            return
        }
        let cellProvider = sections[indexPath.section].cellContexts[indexPath.row]
        cellProvider.didEndDisplayHandlerForSection?(indexPath.section)
    }
}

// This is the way to split UIScrollViewDelegate from UICollectionViewDelegate
extension CollectionViewArchitectorImpl: UIScrollViewDelegate {
    override func responds(to aSelector: Selector!) -> Bool {
        let allMethodsDesribed = protocol_getMethodDescription(UIScrollViewDelegate.self, aSelector, false, true).types != nil ||
        protocol_getMethodDescription(UIScrollViewDelegate.self, aSelector, true, true).types != nil
        
        guard let scrollViewDelegate = scrollViewDelegate, allMethodsDesribed else {
            return super.responds(to: aSelector)
        }
        return scrollViewDelegate.responds(to: aSelector)
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        let allMethodsDesribed = protocol_getMethodDescription(UIScrollViewDelegate.self, aSelector, false, true).types != nil ||
        protocol_getMethodDescription(UIScrollViewDelegate.self, aSelector, true, true).types != nil
        guard allMethodsDesribed else { return nil }
        return scrollViewDelegate
    }
}

extension NSDiffableDataSourceSnapshot {
    func indexPath(for item: ItemIdentifierType) -> IndexPath? {
        let indexPaths: [IndexPath] = sectionIdentifiers.map { sectionIdentifier -> IndexPath? in
            guard let row = self.itemIdentifiers(inSection: sectionIdentifier).firstIndex(of: item),
                  let section = sectionIdentifiers.firstIndex(of: sectionIdentifier) else { return nil }
            return IndexPath(row: row, section: section)
        }
            .compactMap { $0 }
        return indexPaths.first
    }
}
