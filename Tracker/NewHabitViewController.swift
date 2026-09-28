//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 07/09/26.
//

import UIKit

// MARK: - NewHabitViewControllerDelegate

protocol NewHabitViewControllerDelegate: AnyObject {
    func newHabitViewController(_ viewController: NewHabitViewController, didCreate tracker: Tracker)
}

// MARK: - NewHabitViewController

final class NewHabitViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let sideInset: CGFloat = 16
        static let fieldHeight: CGFloat = 75
        static let buttonHeight: CGFloat = 60
        static let cornerRadius: CGFloat = 16
        static let optionCellReuseIdentifier = "optionCell"
        static let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
        static let colors: [UIColor] = [
            .colorSelection1, .colorSelection2, .colorSelection3, .colorSelection4, .colorSelection5, .colorSelection6,
            .colorSelection7, .colorSelection8, .colorSelection9, .colorSelection10, .colorSelection11, .colorSelection12,
            .colorSelection13, .colorSelection14, .colorSelection15, .colorSelection16, .colorSelection17, .colorSelection18
        ].map { UIColor(resource: $0) }
    }

    // MARK: - Public Properties

    weak var delegate: NewHabitViewControllerDelegate?

    // MARK: - Private Properties

    private var schedule: [WeekDay] = []

    private var isCreateButtonEnabled: Bool {
        let isNameFilled = !(nameTextField.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
        return isNameFilled && !schedule.isEmpty
    }

    private var scheduleSubtitle: String? {
        guard !schedule.isEmpty else { return nil }
        if schedule.count == WeekDay.allCases.count {
            return "Каждый день"
        }
        return schedule.map(\.shortTitle).joined(separator: ", ")
    }

    // MARK: - Subviews

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
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

    private let optionTitles = ["Категория", "Расписание"]

    private lazy var optionsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.layer.cornerRadius = Constants.cornerRadius
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: Constants.sideInset, bottom: 0, right: Constants.sideInset)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.layer.cornerRadius = Constants.cornerRadius
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(resource: .ypGray)
        button.layer.cornerRadius = Constants.cornerRadius
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "Новая привычка"
        setupView()
        setupConstraints()
        setupKeyboardDismissRecognizer()
        subscribeToKeyboardNotifications()
        updateCreateButtonState()
        nameTextField.becomeFirstResponder()
    }

    // MARK: - Actions

    @objc private func nameTextFieldChanged() {
        updateCreateButtonState()
    }

    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }

    @objc private func didTapCreateButton() {
        guard let title = nameTextField.text?.trimmingCharacters(in: .whitespaces), !title.isEmpty else { return }

        let tracker = Tracker(
            id: UUID(),
            title: title,
            color: Constants.colors.randomElement() ?? .systemBlue,
            emoji: Constants.emojis.randomElement() ?? "🙂",
            schedule: schedule
        )
        delegate?.newHabitViewController(self, didCreate: tracker)
    }

    // MARK: - Private Methods

    private func setupView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(nameTextField)
        contentView.addSubview(optionsTableView)
        view.addSubview(buttonsStackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -16),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.sideInset),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.sideInset),
            nameTextField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),

            optionsTableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            optionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.sideInset),
            optionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.sideInset),
            optionsTableView.heightAnchor.constraint(equalToConstant: Constants.fieldHeight * 2),
            optionsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideInset),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideInset),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }

    private func setupKeyboardDismissRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
    }

    @objc private func keyboardWillHide() {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    private func updateCreateButtonState() {
        createButton.isEnabled = isCreateButtonEnabled
        createButton.backgroundColor = isCreateButtonEnabled ? UIColor(resource: .ypBlack) : UIColor(resource: .ypGray)
    }
}

// MARK: - UITextFieldDelegate

extension NewHabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - ScheduleViewControllerDelegate

extension NewHabitViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ viewController: ScheduleViewController, didSelect schedule: [WeekDay]) {
        self.schedule = schedule
        updateCreateButtonState()
        optionsTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
    }
}

// MARK: - UITableViewDataSource

extension NewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        optionTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.optionCellReuseIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: Constants.optionCellReuseIdentifier)
        cell.textLabel?.text = optionTitles[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.text = indexPath.row == 1 ? scheduleSubtitle : nil
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = UIColor(resource: .ypGray)
        cell.backgroundColor = UIColor(resource: .ypBackground)
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator

        if indexPath.row == optionTitles.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.fieldHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.row {
        case 1:
            let scheduleViewController = ScheduleViewController(selectedDays: Set(schedule))
            scheduleViewController.delegate = self
            let navigationController = UINavigationController(rootViewController: scheduleViewController)
            present(navigationController, animated: true)
        default:
            break // Экран «Категория» будет реализован в следующих уроках.
        }
    }
}
