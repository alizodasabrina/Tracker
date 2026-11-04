//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 30/10/26.
//

import UIKit

final class NewCategoryViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let sideInset: CGFloat = 16
        static let buttonSideInset: CGFloat = 20
        static let fieldHeight: CGFloat = 75
        static let buttonHeight: CGFloat = 60
        static let cornerRadius: CGFloat = 16
    }

    // MARK: - Private Properties

    private let viewModel: TrackerCategoryViewModel

    // MARK: - Subviews

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("new_category_name_placeholder", comment: "Плейсхолдер поля названия категории"),
            attributes: [.foregroundColor: UIColor(resource: .ypGray)]
        )
        textField.backgroundColor = UIColor(resource: .ypBackground)
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.sideInset, height: 0))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.addTarget(self, action: #selector(nameTextFieldChanged), for: .editingChanged)
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("new_category_done_button", comment: "Кнопка сохранения новой категории"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(resource: .ypGray)
        button.layer.cornerRadius = Constants.cornerRadius
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init

    init(viewModel: TrackerCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = NSLocalizedString("new_category_title", comment: "Заголовок экрана создания категории")
        navigationItem.hidesBackButton = true
        setupView()
        setupConstraints()
    }

    // MARK: - Private Methods

    private func setupView() {
        view.addSubview(nameTextField)
        view.addSubview(doneButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideInset),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideInset),
            nameTextField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.buttonSideInset),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.buttonSideInset),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }

    private func updateDoneButtonState() {
        let title = (nameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let isValid = !title.isEmpty && viewModel.isCategoryNameAvailable(title)
        doneButton.isEnabled = isValid
        doneButton.backgroundColor = isValid ? UIColor(resource: .ypBlack) : UIColor(resource: .ypGray)
    }

    // MARK: - Actions

    @objc private func nameTextFieldChanged() {
        updateDoneButtonState()
    }

    @objc private func didTapDoneButton() {
        guard let title = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else { return }

        do {
            try viewModel.addCategory(title: title)
            navigationController?.popViewController(animated: true)
        } catch {
            assertionFailure("Не удалось создать категорию: \(error)")
        }
    }
}

// MARK: - UITextFieldDelegate

extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
