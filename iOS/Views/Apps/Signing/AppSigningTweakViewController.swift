//
//  AppSigningTweakViewController.swift
//  feather
//
//  Created by samara on 8/15/24.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

class AppSigningTweakViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	var appSigningViewController: AppSigningViewController
	var tweaksToInject: [URL] = [] {
		didSet {
			UIView.animate(withDuration: 0.3) {
				self.appSigningViewController.toInject = self.tweaksToInject 
				self.collectionView.reloadData()
			}
		}
	}
	
	init(appSigningViewController: AppSigningViewController) {
		self.appSigningViewController = appSigningViewController
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		layout.minimumLineSpacing = 16
		layout.minimumInteritemSpacing = 16
		layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		super.init(collectionViewLayout: layout)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Tweaks"
		navigationItem.largeTitleDisplayMode = .never
		collectionView.register(ProductCollectionViewCell.self, forCellWithReuseIdentifier: ProductCollectionViewCell.reuseIdentifier)

		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(openDocuments))
		collectionView.backgroundColor = .systemBackground
		self.tweaksToInject = self.appSigningViewController.toInject
	}
	
	@objc func openDocuments() {
		importFile()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension AppSigningTweakViewController {
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.tweaksToInject.count 
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let layout = collectionViewLayout as! UICollectionViewFlowLayout
		
		let numberOfColumns: CGFloat = 2
		let totalSpacing = layout.minimumInteritemSpacing * (numberOfColumns - 1)
		
		let sectionInsets = layout.sectionInset
		let availableWidth = collectionView.bounds.width - sectionInsets.left - sectionInsets.right - totalSpacing
		
		let cellWidth = availableWidth / numberOfColumns
		
		return CGSize(width: cellWidth, height: cellWidth)
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCollectionViewCell.reuseIdentifier, for: indexPath) as! ProductCollectionViewCell
		let tweak = tweaksToInject[indexPath.item]
		cell.titleLabel.text = "\(tweak.lastPathComponent)"
		
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
			let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
				self.tweaksToInject.remove(at: indexPath.item)
			}
			return UIMenu(title: "", children: [deleteAction])
		}
	}
}

extension AppSigningTweakViewController: UIDocumentPickerDelegate {
	func importFile() {
		self.presentDocumentPicker(fileExtension: [
			UTType(filenameExtension: "deb")!,
			UTType(filenameExtension: "dylib")!
		])
	}
	
	func presentDocumentPicker(fileExtension: [UTType]) {
		let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: fileExtension, asCopy: true)
		documentPicker.delegate = self
		documentPicker.allowsMultipleSelection = false
		present(documentPicker, animated: true, completion: nil)
	}
	
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		guard let selectedFileURL = urls.first else { return }
		
		Debug.shared.log(message: "\(selectedFileURL)")
		
		if !tweaksToInject.contains(selectedFileURL) {
			self.tweaksToInject.append(selectedFileURL)
		}
		
		collectionView.reloadData()
	}



	
	func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
}

class ProductCollectionViewCell: UICollectionViewCell {
	static let reuseIdentifier = "ProductCell"
	
	let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		imageView.image = UIImage(systemName: "doc")
		imageView.tintColor = .secondaryLabel.withAlphaComponent(0.2)
		return imageView
	}()
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .secondaryLabel
		label.textAlignment = .center
		label.numberOfLines = 0
		return label
	}()
	
	private lazy var stackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
		stackView.axis = .vertical
		stackView.spacing = 1
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupViews() {
		contentView.addSubview(stackView)
		contentView.backgroundColor = .quaternarySystemFill
		contentView.layer.cornerRadius = 19
		contentView.layer.cornerCurve = .continuous
		contentView.layer.masksToBounds = true
		
		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
			imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4),
			stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
		])
	}
}


