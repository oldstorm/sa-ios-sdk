//
//  CreateSituationViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/12.
//

import UIKit

class CreateSituationViewController: BaseViewController {
    private lazy var areas = [Area]()

    private lazy var saveButton = Button().then {
        $0.setTitle("保存".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.setTitleColor(.custom(.gray_94a5be), for: .disabled)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.saveButtonClick()
        }
    }

    private lazy var header = AddFamilyHeader(frame: .zero).then {
        $0.textField.delegate = self
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.dataSource = self
        $0.delegate = self
        $0.separatorStyle = .none
        $0.register(AddFamilyAreaCell.self, forCellReuseIdentifier: AddFamilyAreaCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
    }
    
    private lazy var bottomAddAreaButton = BottomButton(frame: .zero, icon: .assets(.plus_blue), title: "添加房间/区域".localizedString, titleColor: .custom(.blue_2da3f6), backgroundColor: UIColor.custom(.white_ffffff))

    private var addAreaAlertView: FamilyAlertView?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "添加".localizedString
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        saveButton.isEnabled = header.textField.text != ""
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f1f4fc)
        view.addSubview(header)
        view.addSubview(tableView)
        view.addSubview(bottomAddAreaButton)
        
        bottomAddAreaButton.clickCallBack = { [weak self] in
            guard let self = self else { return }
            let addAreaAlertView = FamilyAlertView(labelText: "房间/区域名称".localizedString, placeHolder: "请输入房间/区域名称".localizedString) { [weak self] text in
                guard let self = self else { return }
                self.showToast(string: "Save.")
            }
            
            self.addAreaAlertView = addAreaAlertView
            
            SceneDelegate.shared.window?.addSubview(addAreaAlertView)
        }
    }
    
    override func setupConstraints() {
        header.snp.makeConstraints {
            $0.top.right.left.equalToSuperview()
            $0.height.equalTo(120)
        }
        
        bottomAddAreaButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(header.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(bottomAddAreaButton.snp.top).offset(-18.5)
        }
    }
}

extension CreateSituationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AddFamilyAreaCell.reusableIdentifier, for: indexPath) as! AddFamilyAreaCell
        cell.area = areas[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        areas[indexPath.row].chosen = !areas[indexPath.row].chosen
        tableView.reloadRows(at: [indexPath], with: .none)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

extension CreateSituationViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let text = textField.text ?? ""
        if text.count > 30 {
            textField.text = String(text.prefix(30))
        }
        
        
        
        if textField.text?.replacingOccurrences(of: " ", with: "").count == 0 {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = (text.count > 0)
        }
        
    }
}

extension CreateSituationViewController {
    func saveButtonClick() {
        guard let name = header.textField.text else { return }
        
        let areas_name = areas
            .filter { $0.chosen }
            .map(\.name)

        apiService.requestModel(.createSituation(name: name, areas_name: areas_name), modelType: BaseModel.self) { [weak self] (response) in
            guard let self = self else { return }
            self.showToast(string: "添加成功".localizedString)
            self.navigationController?.popViewController(animated: true)
        }
    }
    

    func getDefaultAreas() {
        apiService.requestModel(.defaultAreasList, modelType: DefaultAreasResponse.self) { [weak self] (response) in
            guard let response = response else {
                let area0 = Area()
                area0.name = "主人房"
                let area1 = Area()
                area1.name = "客厅"
                let area2 = Area()
                area2.name = "书房"
                let area3 = Area()
                area3.name = "卫生间"
                self?.areas = [area0, area1, area2, area3]
                self?.tableView.reloadData()
                return
            }
            
            self?.areas = response.areas
            self?.tableView.reloadData()
        }
    }
    
    
    

}


// MARK: - RequestModels
extension CreateSituationViewController {
    class DefaultAreasResponse: BaseModel {
        var areas = [Area]()
    }
}
