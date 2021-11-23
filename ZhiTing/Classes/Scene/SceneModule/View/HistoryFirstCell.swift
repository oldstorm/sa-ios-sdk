//
//  HistoryFirstCell.swift
//  ZhiTing
//
//  Created by mac on 2021/4/13.
//

import UIKit

class HistoryFirstCell: UITableViewCell,ReusableView {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var callback: ((_ section: Int, _ tag: Int, _ isOpen: Bool) -> ())?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    var currentModelArray : [SceneHistoryMonthItemModel]? {
        didSet{
            guard let dataArray = currentModelArray else { return }
            dataArray.forEach{_ in
                //所有的分区都是闭合
                stateArray.append("0")
            }
            setupViews()
            //设置model，重新刷新UI
            DispatchQueue.main.async {[weak self] in
                self?.tableView.reloadData()
            }

        }
    }
    
    //tableView
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.white_ffffff)
        $0.estimatedSectionHeaderHeight = 10
        $0.estimatedSectionFooterHeight = 0
        $0.separatorStyle = .none
        $0.contentInset.top = ZTScaleValue(10)
        $0.contentInset.bottom = ZTScaleValue(10)
        $0.isScrollEnabled = false
        //创建场景Cell
        $0.register(HistorySecondCell.self, forCellReuseIdentifier: HistorySecondCell.reusableIdentifier)

        $0.alwaysBounceVertical = false
    }
    
    private var stateArray = [String]()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupViews(){
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints{
            $0.top.left.right.bottom.equalToSuperview()
        }
    }
    
    override func prepareForReuse() {
        tableView.removeFromSuperview()
    }

}

extension HistoryFirstCell {
    private func creatHeaderView(index: Int) -> UIView{//创建分区头内容
        guard let sceneModel = currentModelArray?[index] else {
            return UIView()
        }
        
        let button = UIButton.init(type: .custom)
        button.backgroundColor = .custom(.white_ffffff)
        button.tag = index+1
        //标题原点
        let titlePoint = UIView()
        titlePoint.backgroundColor = .custom(.gray_eeeeee)
        titlePoint.layer.cornerRadius = ZTScaleValue(6.0)
        titlePoint.layer.masksToBounds = true
        button.addSubview(titlePoint)
        
        //过度线
        let line = UIView()
        line.backgroundColor = .custom(.gray_eeeeee)
        button.addSubview(line)
        
        //标题
        let title = UILabel()
        title.font = .font(size: ZTScaleValue(14), type: .medium)
        title.textColor = .custom(.black_3f4663)
        title.text = sceneModel.name
        title.numberOfLines = 0
        button.addSubview(title)
        
        //结果
        var resultStr = " "
        let result = UILabel()
        result.font = .font(size: ZTScaleValue(12), type: .medium)
        
        //任务结果:1执行完成;2部分执行完成;3执行失败;4执行超时;5设备已被删除;6设备离线;7场景已被删除
        switch sceneModel.result {
        case 1:
            resultStr = "执行成功"
           result.textColor = .custom(.black_3f4663)

        case 2:
            resultStr = "部分执行成功"
           result.textColor = .custom(.yellow_f3a934)
        case 3:
            resultStr = "执行失败"
           result.textColor = .custom(.red_fe0000)
        case 4:
            resultStr = "执行超时"
           result.textColor = .custom(.red_fe0000)
        case 5:
            resultStr = "设备已被删除"
           result.textColor = .custom(.red_fe0000)
        case 6:
            resultStr = "设备离线"
           result.textColor = .custom(.red_fe0000)
        case 7:
            resultStr = "场景已被删除"
           result.textColor = .custom(.red_fe0000)
        default:
            resultStr = ""
        }
        let dateStr = DateFormatter()
        dateStr.dateFormat = "MM月dd日 HH:mm"
        let date = Date.init(timeIntervalSince1970: TimeInterval(sceneModel.finished_at))
        result.text =  dateStr.string(from: date).appending(String(format: "  %@", resultStr))
//sceneModel.date.appending(" \(sceneModel.time) \(resultStr)")
        button.addSubview(result)
        
        //添加约束
        
        titlePoint.snp.makeConstraints{
            $0.top.equalTo(ZTScaleValue(25.0))
            $0.centerX.equalTo(button.snp.left).offset(ZTScaleValue(30.0))
            $0.width.height.equalTo(ZTScaleValue(12))
        }
        
        //起点原点
        if index == 0 {//第一个
            let starPoint = UIView()
            starPoint.backgroundColor = .custom(.gray_eeeeee)
            starPoint.layer.cornerRadius = ZTScaleValue(3.0)
            starPoint.layer.masksToBounds = true
            button.addSubview(starPoint)
            
            starPoint.snp.makeConstraints{
                $0.top.equalTo(ZTScaleValue(0))
                $0.centerX.equalTo(titlePoint)
                $0.width.height.equalTo(ZTScaleValue(6))
            }

        }


        //箭头
        if sceneModel.items.count != 0 {
            let arrowIcon = UIImageView()
            if stateArray[index] == "0" {
                arrowIcon.image = .assets(.arrow_down)
            }else{
                arrowIcon.image = .assets(.arrow_up)
            }
            button.addSubview(arrowIcon)
            arrowIcon.snp.makeConstraints{
                $0.centerY.equalTo(titlePoint)
                $0.right.equalTo(-ZTScaleValue(30.0))
                $0.width.equalTo(ZTScaleValue(13.5))
                $0.height.equalTo(ZTScaleValue(8.0))
            }
        }

        
        line.snp.makeConstraints{
            $0.top.bottom.equalToSuperview()
            $0.centerX.equalTo(titlePoint)
            $0.width.equalTo(ZTScaleValue(2.0))
        }
        
        title.snp.makeConstraints{
            $0.top.equalTo(titlePoint)
            $0.left.equalTo(line).offset(ZTScaleValue(30.0))
            $0.width.lessThanOrEqualTo(ZTScaleValue(250))
//            $0.right.equalToSuperview().offset(-ZTScaleValue(50))
//            $0.height.greaterThanOrEqualTo(ZTScaleValue(13))
        }

        result.snp.makeConstraints{
            $0.top.equalTo(title.snp.bottom).offset(ZTScaleValue(8.5))
            $0.left.equalTo(title)
            $0.height.lessThanOrEqualTo(ZTScaleValue(11.5))
        }
        
        //结束原点
        if index == currentModelArray!.count - 1{//最后一个
            let endPoint = UIView()
            endPoint.backgroundColor = .custom(.gray_eeeeee)
            endPoint.layer.cornerRadius = ZTScaleValue(3.0)
            endPoint.layer.masksToBounds = true

            button.addSubview(endPoint)
            endPoint.snp.makeConstraints{
                $0.bottom.equalTo(ZTScaleValue(0))
                $0.centerX.equalTo(titlePoint)
                $0.width.height.equalTo(ZTScaleValue(6))
            }
        }
        
        button.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        return button
    }
    
    @objc private func buttonPress(sender: UIButton){
        if currentModelArray?[sender.tag - 1].items.count != 0 {
            if stateArray[sender.tag - 1] == "1" {//关闭
                stateArray[sender.tag - 1] = "0"
                callback?(tag - 1,sender.tag-1,false)
            }else{//展开
                stateArray[sender.tag - 1] = "1"
                callback?(tag - 1,sender.tag-1,true)
            }
//            tableView.reloadData()
//            tableView.reloadSections(IndexSet(integer: sender.tag - 1), with: .automatic)
        }
    }
}
    
extension HistoryFirstCell: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if currentModelArray != nil {
            return currentModelArray!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //构建分区头
        return creatHeaderView(index: section)
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sceneModel = currentModelArray?[section]
        let str = sceneModel?.name ?? ""
        let font = UIFont.systemFont(ofSize: ZTScaleValue(14))
        let attributes = [NSAttributedString.Key.font:font]
        let rect:CGRect = str.boundingRect(with: CGSize(width:ZTScaleValue(300), height:24), attributes: attributes)
        print("rect:\(rect)")
        if rect.width > ZTScaleValue(250) {
            return ZTScaleValue(100.0)
        }else{
            return ZTScaleValue(80)
        }
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if currentModelArray?[indexPath.section].items[indexPath.row].location_name == ""{
            return ZTScaleValue(50.0)
        }else{
            return ZTScaleValue(70.0)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if stateArray[section] == "1" {//如果是展开状态
                return currentModelArray?[section].items.count ?? 0
            }else{
                //如果是闭合，返回0
                return 0
            }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistorySecondCell.reusableIdentifier, for: indexPath) as! HistorySecondCell
        cell.backgroundColor = .custom(.white_ffffff)
        let sceneModel = currentModelArray![indexPath.section]
        let devicemodel = sceneModel.items[indexPath.row]
        if indexPath.section + 1 == currentModelArray?.count {
            cell.isLastSection = true
        }else{
            cell.isLastSection = false
        }
        if indexPath.row + 1 == sceneModel.items.count {
            cell.isLastObject = true
        }else{
            cell.isLastObject = false
        }
        cell.currentModel = devicemodel
        cell.selectionStyle = .none
        return cell
    }

}
