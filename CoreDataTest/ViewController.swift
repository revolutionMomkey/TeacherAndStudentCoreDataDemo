//
//  ViewController.swift
//  CoreDataTest
//
//  Created by 杜俊楠 on 2023/5/3.
//

import UIKit


class ViewController: UIViewController {

    private static let BTNTAG = 74751
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var teacherArray: [Teacher] = [];
    private var studentArray: [Student] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

}

extension ViewController {
    
    func setUI() {
        
        let btnTitleArray = ["生成数据(老师+学生)","展示数据","删除老师数据","删除学生数据","所有学生分配给1号老师并保存","根据课程匹配师生并保存"]
        
        for index in 0..<btnTitleArray.count {
            
            let btn = UIButton(type: .custom)
            btn.frame = CGRect(x: 50, y: 100 + index * 80, width: 300, height: 50)
            btn.setTitle(btnTitleArray[index], for: .normal)
            btn.setTitleColor(.black, for: .normal)
            btn.layer.borderColor = UIColor.black.cgColor
            btn.layer.borderWidth = 1
            btn.tag = ViewController.BTNTAG+index
            btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
            view.addSubview(btn)
        }
        
    }
}
//btn触发方法,数据的生成/删除方法
extension ViewController {
   
    @objc func btnAction(_ sender: UIButton) {
        
        switch sender.tag - ViewController.BTNTAG {
        case 0: do {
            makeData()
        }
        case 1: do {
            getDataShow()
        }
        case 2: do {
            deleteTeacherData()
        }
        case 3: do {
            deleteStuData()
        }
        case 4: do {
            allStudentsToTeacherWhosId1()
        }
        case 5: do {
            matchTeachWithStudents()
        }
        default:
            break
        }
    }
    
    func makeData() {
        //模仿在业务中生成老师数据,老师的model由coreData生成
        setTeacherData()
        //模仿在业务中生成学生数据,学生的model由coreData生成
        setStudentData()
        print("数据生成完毕")
        getDataShow()
    }
    
    func allStudentsToTeacherWhosId1() {
        
        guard teacherArray.count != 0 else {
            return print("先生成老师数据")
        }
        let teacher = teacherArray[0]
        
        for student in studentArray {
            if let teacherTeahStudentRelationship = teacher.teacherTeahStudents as? NSMutableOrderedSet {
                teacherTeahStudentRelationship.add(student)
                student.stuLearnFromTeacher = teacher
            } else {
                teacher.teacherTeahStudents = NSMutableOrderedSet(object: student)
            }
        }
        
        let book = WorkBook(context: context)
        book.name = "id1号老师的教案"
        teacher.teacherUseWorkBook = book
        saveData()
        sleep(1)
        getDataShow()
    }
    
    func matchTeachWithStudents() {
        
        guard teacherArray.count != 0 else {
            return print("需要生成老师数据")
        }
        guard studentArray.count != 0 else {
            return print("需要生成学生数据")
        }
        let tempStudents = self.studentArray
        for teacher in teacherArray {
            if tempStudents.count != 0 {
                for student in studentArray {
                    if let teacherTeahStudentRelationship = teacher.teacherTeahStudents as? NSMutableOrderedSet, teacher.subject == student.classSubject {
                        teacherTeahStudentRelationship.add(student)
                        student.stuLearnFromTeacher = teacher
                    }
                }
                
            }
            else {
                continue
            }
    
            let book = WorkBook(context: context)
            book.name = "\(teacher.id)号老师的\(teacher.subject ?? "")教案"
            teacher.teacherUseWorkBook = book
        }
        
        saveData()
        sleep(1)
        getDataShow()
    }
    
    func getDataShow() {
        
        let stuRequest = Student.fetchRequest()
        do {
            let students = try context.fetch(stuRequest)
            for student in students {
                print("Student: \(student.id)")
                studentArray.append(student)
                if let stuLearnFromTeacherRelationShip = student.stuLearnFromTeacher {
                    print("  \(student.id)Student的老师是: \(stuLearnFromTeacherRelationShip)")
                }
            }
        } catch  {
            print("学生数据没取出来\(error)")
        }
        if studentArray.count == 0 {
            print("学生数据没数据")
        }
        else {
            print("---学生数据打印完毕--- \n")
        }
        
        
        let request = Teacher.fetchRequest()
//        request.relationshipKeyPathsForPrefetching = ["teacherTeahStudents"]
        do {
            let teachers = try context.fetch(request)
            for teacher in teachers {
                print("Teacher id: \(teacher.id)")
                teacherArray.append(teacher)
                for student in teacher.teacherTeahStudents ?? [] {
                    print("  Student: \(student)\n  \(String(describing: (student as AnyObject).classSubject))")
                }
//                print("Teacher teahStudents: \(String(describing: teacher.teacherTeahStudents as! NSMutableOrderedSet))")
            }
        } catch  {
            print("老师数据没取出来\(error)")
        }
        if teacherArray.count == 0 {
            print("老师数据没数据")
        }
        else {
            print("---老师数据打印完毕--- \n")
        }
    
    }
    
    func deleteTeacherData() {
        
        let request = Teacher.fetchRequest()
        do {
            let dataArray = try context.fetch(request)
            print("---老师数据删除之前---")
            print(dataArray)
            for item in dataArray {
                context.delete(item)
            }
            try context.save()
            print("---老师数据删除完了---")
        } catch  {
            print("老师数据删除出错了\(error)")
        }
        teacherArray.removeAll()
    }
    
    func deleteStuData() {
        
        let request = Student.fetchRequest()
        do {
            let dataArray = try context.fetch(request)
            print("---学生数据删除之前---")
            print(dataArray)
            for item in dataArray {
                context.delete(item)
            }
            try context.save()
            print("---学生数据删除完了---")
        } catch  {
            print("学生数据删除出错了\(error)")
        }
        studentArray.removeAll()
    }
    
    func saveData() {
        do {
            try context.save()
        } catch  {
            print("保存出错\(error)")
        }
    }
}

extension ViewController {
    
    func setTeacherData() {
        
        let teacherSubjectArr = ["语文","数学","英语","物理","历史","化学","政治","地理","生物"]
        
        for index in 0..<teacherSubjectArr.count {
            let teacher = Teacher(context:context)
            teacher.id = Int16(1+index)
            teacher.subject = teacherSubjectArr[index]
            teacherArray.append(teacher)
        }
    }
    
    func setStudentData() {
        
        let studentClassSubjectArr = ["历史","数学","物理","数学","数学","历史"]
        
        for index in 0..<studentClassSubjectArr.count {
            
            let student = Student(context:context)
            student.id = Int16(2301+index)
            student.classSubject = studentClassSubjectArr[index]
            studentArray.append(student)
        }
    }
    
}
