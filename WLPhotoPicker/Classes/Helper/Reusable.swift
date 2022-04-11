//
//  Reusable.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/11.
//

import UIKit

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: Reusable {}
extension UITableViewHeaderFooterView: Reusable {}
extension UICollectionReusableView: Reusable {}

extension UITableView {
    
    func register<Cell: UITableViewCell>(_ cellType: Cell.Type) {
        register(cellType, forCellReuseIdentifier: Cell.reuseIdentifier)
    }
    
    func dequeueReusableCell<Cell: UITableViewCell>(_ cellType: Cell.Type) -> Cell {
        guard let cell = dequeueReusableCell(withIdentifier: Cell.reuseIdentifier) as? Cell else {
            fatalError("Should register cell --- \(Cell.reuseIdentifier) first.")
        }
        return cell
    }
    
    func register<View: UITableViewHeaderFooterView>(_ viewType: View.Type) {
        register(viewType, forHeaderFooterViewReuseIdentifier: View.reuseIdentifier)
    }
    
    func dequeueReusableView<View: UITableViewHeaderFooterView>(_ viewType: View.Type) -> View {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: View.reuseIdentifier) as? View else {
            fatalError("Should register view --- \(View.reuseIdentifier) first.")
        }
        return view
    }
}

extension UICollectionView {
    
    func register<Cell: UICollectionViewCell>(_ cellType: Cell.Type) {
        register(cellType, forCellWithReuseIdentifier: Cell.reuseIdentifier)
    }
    
    func dequeueReusableCell<Cell: UICollectionViewCell>(_ cellType: Cell.Type, for indexPath: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("Should register view --- \(Cell.reuseIdentifier) first.")
        }
        return cell
    }
    
    func register<View: UICollectionReusableView>(_ viewType: View.Type, forSupplementaryViewOfKind kind: String) {
        register(viewType, forSupplementaryViewOfKind: kind, withReuseIdentifier: View.reuseIdentifier)
    }
    
    func registerHeader<View: UICollectionReusableView>(_ viewType: View.Type) {
        register(viewType, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
    }
    
    func registerFooter<View: UICollectionReusableView>(_ viewType: View.Type) {
        register(viewType, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter)
    }
    
    func dequeueReusableView<View: UICollectionReusableView>(_ viewType: View.Type, ofKind: String, for indexPath: IndexPath) -> View {
        guard let view = dequeueReusableSupplementaryView(ofKind: ofKind, withReuseIdentifier: View.reuseIdentifier, for: indexPath) as? View else {
            fatalError("Should register view --- \(View.reuseIdentifier) first.")
        }
        return view
    }
    
}
