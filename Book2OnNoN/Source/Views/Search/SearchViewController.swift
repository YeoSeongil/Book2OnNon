//
//  SearchViewController.swift
//  Book2OnNoN
//
//  Created by 여성일 on 3/11/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import DropDown

class SearchViewController: BaseViewController {

    private let viewModel: SearchViewModelType
    
    // MARK: UI Components
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "검색어를 입력하세요."
        textField.borderStyle = .none
        textField.textColor = .black
        return textField
    }()
    
    private lazy var searchDropDownButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("제목", for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private lazy var searchOptionDropDown: DropDown = {
         let dropDown = DropDown()
         dropDown.anchorView = searchDropDownButton
         return dropDown
     }()

    private lazy var searchResultTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.id)
        tableView.backgroundColor = .white
        return tableView
    }()
    
    // MARK: init
    init(viewModel: SearchViewModelType = SearchViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: SetUp ViewController
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchTextField.layer.addBorder(edge: .bottom, color: .black, thickness: 2.0)
    }
    
    override func setViewController() {
        view.backgroundColor = .white
    }
    
    override func setAddViews() {
        [searchTextField, searchDropDownButton, searchResultTableView].forEach {
            view.addSubview($0)
        }
    }
    
    override func setConstraints() {
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().offset(60)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
        
        searchDropDownButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(5)
            $0.trailing.equalTo(searchTextField.snp.leading)
            $0.height.equalTo(50)
        }
        
        searchResultTableView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(5)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(5)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(5)
        }
    }
    
    override func bind() {
        // Input
        searchDropDownButton.rx.tap
            .asObservable()
            .bind(to: viewModel.searchDropDownButtonTapped)
            .disposed(by: disposeBag)
        
        searchTextField.rx.text.orEmpty
            .asObservable()
            .bind(to: viewModel.searchTextFieldInputTextValue)
            .disposed(by: disposeBag)
        
        searchTextField.rx.controlEvent(.editingDidEnd)
            .asObservable()
            .bind(to: viewModel.searchEditingDidEnd)
            .disposed(by: disposeBag)
        
        searchOptionDropDown.rx.selectionAction.onNext { [weak self] index, item in
            self?.searchDropDownButton.setTitle(item, for: .normal)
            self?.viewModel.whichSelectedDropDownItem.onNext(item)
        }
            
        // Output
        viewModel.resultDownButtonTapped
            .asDriver()
            .drive(onNext: {[weak self] data in
                self?.searchOptionDropDown.show()
                self?.searchOptionDropDown.dataSource = data
            }).disposed(by: disposeBag)
        
        searchResultTableView.rx.setDelegate(self).disposed(by: disposeBag)
        viewModel.resultSearchItem
            .drive(searchResultTableView.rx.items(cellIdentifier: SearchResultTableViewCell.id, cellType: SearchResultTableViewCell.self)) { row, item, cell in
                cell.configuration(book: item)
            }.disposed(by: disposeBag)
    }
    
    private func showDropDown() {
        searchOptionDropDown.show()
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100.0)
    }
}

