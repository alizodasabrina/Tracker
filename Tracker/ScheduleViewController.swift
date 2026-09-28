//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 07/09/26.
//

import UIKit

// MARK: - ScheduleViewControllerDelegate

protocol ScheduleViewControllerDelegate: AnyObject {
    func scheduleViewController(_ viewController: ScheduleViewController, didSelect schedule: [WeekDay])
}

// MARK: - ScheduleViewController

final class ScheduleViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let rowHeight: CGFloat = 75
        static let cornerRadius: CGFloat = 16
        static let sideInset: CGFloat = 16
        static let doneButtonHeight: CGFloat = 60
        static let doneButtonBottomInset: CGFloat = 16
        static let reuseIdentifier = "scheduleCell"
    }

    // MARK: - Public Properties

    weak var delegate: ScheduleViewControllerDelegate?

    // MARK: - Private Properties

    private var selectedDays: Set<WeekDay>
    // Отображаем с понедельника, а не в порядке rawValue (там неделя начинается с воскресенья).
    private let weekDays: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

    // MARK: - Subviews

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.layer.cornerRadius = Constants.cornerRadius
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: Constants.sideInset, bottom: 0, right: Constants.sideInset)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(resource: .ypBlack)
        button.layer.cornerRadius = Constants.cornerRadius
        button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init

    init(selectedDays: Set<WeekDay> = []) {
        self.selectedDays = selectedDays
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
        title = "Расписание"
        setupView()
        setupConstraints()
    }

    // MARK: - Actions

    @objc private func didTapDoneButton() {
        let orderedSchedule = weekDays.filter { selectedDays.contains($0) }
        delegate?.scheduleViewController(self, didSelect: orderedSchedule)
        dismiss(animated: true)
    }

    @objc private func switchChanged(_ sender: UISwitch) {
        guard let day = weekDays[safe: sender.tag] else { return }
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }

    // MARK: - Private Methods

    private func setupView() {
        view.addSubview(tableView)
        view.addSubview(doneButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideInset),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideInset),
            tableView.heightAnchor.constraint(equalToConstant: Constants.rowHeight * CGFloat(weekDays.count)),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideInset),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideInset),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.doneButtonBottomInset),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.doneButtonHeight)
        ])
    }

}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekDays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reuseIdentifier, for: indexPath)
        let day = weekDays[indexPath.row]

        cell.textLabel?.text = day.title
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(resource: .ypBackground)

        let daySwitch = UISwitch()
        daySwitch.tag = indexPath.row
        daySwitch.isOn = selectedDays.contains(day)
        daySwitch.onTintColor = UIColor(resource: .ypBlue)
        daySwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        cell.accessoryView = daySwitch

        if indexPath.row == weekDays.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.rowHeight
    }
}

// MARK: - Array safe subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
