//
//  ViewControllerEdit.swift
//  AppAgenda
//
//  Created by HP on 5/22/20.
//  Copyright © 2020 HP. All rights reserved.
//

import UIKit
import SQLite3
class ViewControllerEdit: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource
{
    
    var db : OpaquePointer?
    var Agendas = [Agenda]()
    
    let dataJsonUrlClass = JsonClass()
    
    var vcEdit: Agenda?
    @IBOutlet weak var txtIdAgenda: UITextField!
    @IBOutlet weak var txtTema: UITextField!
    @IBOutlet weak var txtTitulo: UITextField!
    @IBOutlet weak var txtNota: UITextView!
    
    let Temas = ["Tarea","Deporte","Compra","Deveres Casa"]
    
    let pickerView = UIPickerView()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //---------rellema ----------------------------
        txtIdAgenda.text = vcEdit?.idAge
        txtTitulo.text = vcEdit?.tituloAge
        txtTema.text = vcEdit?.temaAge
        txtNota.text = vcEdit?.notaAge
        
        //--------------------dropdown---------------------------------
        pickerView.delegate = self
        pickerView.dataSource = self
        
        txtTema.inputView = pickerView
        txtTema.textAlignment = .center
        txtTema.placeholder = "Select of Tema"
        
        //-----------------------sqlite----------------------------------
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) .appendingPathComponent("BDSQLiteAgendas.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
            showAlerta(Titulo: "Error", Mensaje: "Nose pudo abrir la base de datos")
            return
        }
        let createTable = "CREATE TABLE  IF NOT EXISTS agenda(idAgenda INTEGER PRIMARY KEY autoincrement, titulo TEXT, nomTema TEXT, nota TEXT)"
        if sqlite3_exec(db, createTable, nil, nil, nil) != SQLITE_OK{
            showAlerta(Titulo: "Error", Mensaje: "No se pudo crear la tabla")
            return
            
        }
        showAlerta(Titulo: "Creacion Base de Datos", Mensaje: "DB Creada")
    }
    
    @IBAction func btnEdita(_ sender: UIButton)
    {
        //----------------------------sqlite---------------------------------
        if txtTitulo.text!.isEmpty || txtTema.text!.isEmpty || txtNota.text!.isEmpty || txtIdAgenda.text!.isEmpty
        {
            let alertView = UIAlertController(title:"Faltandatos ",message: "completar", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alertView,animated: true,completion: nil)
            txtTitulo.becomeFirstResponder()
        }else
        {
            let tit = txtTitulo.text?.trimmingCharacters(in: .whitespacesAndNewlines) as! NSString
            let tem = txtTema.text?.trimmingCharacters(in: .whitespacesAndNewlines) as! NSString
            let not = txtNota.text?.trimmingCharacters(in: .whitespacesAndNewlines) as! NSString
            let idAg = txtIdAgenda.text?.trimmingCharacters(in: .whitespacesAndNewlines) as! NSString
            
            var stmt: OpaquePointer?
            let sentencia = "UPDATE agenda SET titulo=?,nomTema=?,nota=? WHERE idAgenda=? "
            
            if sqlite3_prepare(db, sentencia, -1, &stmt, nil) != SQLITE_OK{
                showAlerta(Titulo: "Error", Mensaje: "Error al lugar sentencia")
                return
            }
            if sqlite3_bind_text(stmt, 1, tit.utf8String, -1, nil) != SQLITE_OK{
                showAlerta(Titulo: "Error", Mensaje: "En el 1er parametro titulo")
                return
            }
            if sqlite3_bind_text(stmt, 2, tem.utf8String, -1, nil) != SQLITE_OK{
                showAlerta(Titulo: "Error", Mensaje: "En el 2do parametro Tema")
                return
            }
            if sqlite3_bind_text(stmt, 3, not.utf8String, -1, nil) != SQLITE_OK{
                showAlerta(Titulo: "Error", Mensaje: "En el 3er parametro nota")
                return
            }
            
            if sqlite3_bind_int(stmt, 4, (idAg as NSString).intValue) != SQLITE_OK{
                showAlerta(Titulo: "Error", Mensaje: "En el 1 er parametro cve")
                return
            }
            if sqlite3_step(stmt) == SQLITE_DONE{
                showAlerta(Titulo: "Actualizando", Mensaje: "Agenda actualizada en la DB")
            }else{
                showAlerta(Titulo: "Error", Mensaje: "Agenda no actualizada")
                return
            }
            txtNota.text = ""
            txtTema.text = ""
            txtTitulo.text = ""
            txtIdAgenda.text = ""
            self.performSegue(withIdentifier: "segueHome", sender: self)
            
        }//else
        //----------------------------web sevice-----------------------------
        
        self.performSegue(withIdentifier: "segueHome", sender: self)
    }
    @IBAction func btnElimina(_ sender: UIButton)
    {
        //----------------------------sqlite---------------------------------
        if (txtIdAgenda.text?.isEmpty)! {
            let alertView = UIAlertController(title:"Faltandatos ",message: "completar", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alertView,animated: true,completion: nil)
            txtIdAgenda.becomeFirstResponder()
        }else
        {
            let idAg = txtIdAgenda.text?.trimmingCharacters(in: .whitespacesAndNewlines) as! NSString
            
            var stmt: OpaquePointer?
            let sentencia = "DELETE FROM agenda WHERE idAgenda= ?"
            
            if sqlite3_prepare(db, sentencia, -1, &stmt, nil) != SQLITE_OK{
                showAlerta(Titulo: "Error", Mensaje: "Error al lugar sentencia")
                return
            }
            if sqlite3_bind_int(stmt, 1, (idAg as NSString).intValue) != SQLITE_OK
            {
                showAlerta(Titulo: "Error", Mensaje: "En el 1 er parametro cve")
                return
            }
            if sqlite3_step(stmt) == SQLITE_DONE{
                showAlerta(Titulo: "Eliminando", Mensaje: "Agenda Elimindada de la DB")
            }else{
                showAlerta(Titulo: "Error", Mensaje: "Agenda no Eliminada")
                return
            }
            
            txtNota.text = ""
            txtTema.text = ""
            txtTitulo.text = ""
            txtIdAgenda.text = ""
           self.performSegue(withIdentifier: "segueHome", sender: self)
            
        }//else
        //----------------------------web sevice-----------------------------
        self.performSegue(withIdentifier: "segueHome", sender: self)
    }
    
    
func showAlerta(Titulo: String, Mensaje: String )
{
    // Crea la alerta
    let alert = UIAlertController(title: Titulo, message: Mensaje, preferredStyle: UIAlertController.Style.alert)
    // Agrega un boton
    alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertAction.Style.default, handler: nil))
    // Muestra la alerta
    self.present(alert, animated: true, completion: nil)
}
    
    //-----------------------------dropdown-----------------------------------------
    public func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return Temas.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Temas[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
        txtTema.text = Temas[row]
        txtTema.resignFirstResponder()
    }
    
}//clase
