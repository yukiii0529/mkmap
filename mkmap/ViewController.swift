//
//  ViewController.swift
//  mkmap
//
//  Created by WEB on 2020/07/10.
//  Copyright © 2020 WEB. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController ,UITextFieldDelegate,CLLocationManagerDelegate,MKMapViewDelegate{

    @IBOutlet weak var Map: MKMapView!
    @IBOutlet weak var searchtext: UITextField!
    var myLocationManager:CLLocationManager!
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    
    
    let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    
    let pin = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let center = CLLocationCoordinate2D(latitude: 35.6916554,longitude: 139.6947481)
        
        latitude.text = "緯度：35.6916554"
        longitude.text = "経度：139.6947481"
        
        let region = MKCoordinateRegion(center: center, span: span)
        Map.setRegion(region, animated:true)
        
        pin.coordinate = center
        pin.title="HAL東京"
        pin.subtitle = "https://www.hal.ac.jp/tokyo"
        Map.addAnnotation(pin)
        
        searchtext.delegate = self
        
        //トラッキング関連
        myLocationManager = CLLocationManager()
        
        myLocationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            myLocationManager.delegate = self
        }
        
        Map.delegate = self
        
    }
    
    // リンク関連
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            view.rightCalloutAccessoryView = UIButton(type: UIButton.ButtonType.infoLight)
        }
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
    calloutAccessoryControlTapped control: UIControl) {
        let strUrl:String = view.annotation!.subtitle! ?? ""
        if let url = URL(string: strUrl){ // urlに値がある時
            UIApplication.shared.open(url)
        }

    }
    
    // HAL大阪、大阪駅、HAL名古屋のボタンクリック動作にに関するfunc
    func makePin(latitude lat:Double, longitude long:Double ,title:String, subtitle:String){
        let center = CLLocationCoordinate2D(latitude: lat,longitude: long)
        
        let region = MKCoordinateRegion(center: center, span: span)
        Map.setRegion(region, animated:true)
        
        pin.coordinate = center
        pin.title = title
        pin.subtitle = subtitle
        Map.addAnnotation(pin)
    }
    
    // HAL大阪、大阪駅、HAL名古屋のボタンクリック動作
    @IBAction func canselbutton(_ sender: Any) {
        searchtext.text = ""
    }
    @IBAction func Button(_ sender: Any) {
        let buttonTagButton:UIButton = sender as! UIButton
        print(buttonTagButton.tag)
        let buttonTag = buttonTagButton.tag
        switch  buttonTag {
        case 0:
            makePin(latitude: 34.699875, longitude: 135.493032, title: "HAL大阪", subtitle: "https://www.hal.ac.jp/osaka")
            latitude.text = "緯度：35.699875"
            longitude.text = "経度：135.493032"
        case 1:
            makePin(latitude: 34.702548, longitude: 135.495961, title: "大阪駅", subtitle: "https://www.jr-odekake.net/eki/premises?id=0610130")
            latitude.text = "緯度：35.702548"
            longitude.text = "経度：135.495961"
        case 2:
            makePin(latitude: 35.168122, longitude: 136.885626, title: "HAL名古屋", subtitle: "https://www.hal.ac.jp/nagoya")
            latitude.text = "緯度：35.168122"
            longitude.text = "経度：136.885626"
        default:
            break
        }
    }
    
    // Mapのタイプ変更
    @IBAction func ChangeMap(_ sender: UIButton) {
        if Map.mapType == .hybrid{
            Map.mapType = .standard
        }else if Map.mapType == .standard{
            Map.mapType = .satellite
        }else if Map.mapType == .satellite{
            Map.mapType = .hybrid
        }
    }
    
    // 検索関連
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        // キーボードを閉じる
        searchtext.resignFirstResponder()
        
        // 入力された文字の取得
        if let searchKey = textField.text{
            
            print(searchKey)
            
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(searchKey, completionHandler: {(placemarks: [CLPlacemark]?,error:Error?) in
                
                if let placemark = placemarks?[0]{
                    if placemark.location?.coordinate != nil{ //targetCoordinateに緯度経度が必ず入っている
                        if let targetCoordinate = placemark.location?.coordinate{
                            self.latitude.text = "緯度：" + (placemark.location?.coordinate.latitude.description)!
                            self.longitude.text = "経度：" + (placemark.location?.coordinate.longitude.description)!

                            let region = MKCoordinateRegion(center: targetCoordinate, span: self.span)
                            self.Map.setRegion(region, animated:true)
                            
                            self.pin.coordinate = targetCoordinate
                            self.pin.title = searchKey
                            self.pin.subtitle = ""
                            self.Map.addAnnotation(self.pin)
                        }
                    }
                }
            }
                            
        )}
        return true
    }
    
    var nowAnnotations: [MKAnnotation] = [ ]
    
    //緯度・経度情報(GPS)が変わった時に動く
    func locationManager(_ manager:
        CLLocationManager,didUpdateLocations locations: [CLLocation]) {
        
        if let location = manager.location?.coordinate{
            print("緯度:"+(manager.location?.coordinate.latitude.description)!)
            print("経度:"+(manager.location?.coordinate.longitude.description)!)
            
            latitude.text = "緯度：" + (manager.location?.coordinate.latitude.description)!
            longitude.text = "経度：" + (manager.location?.coordinate.longitude.description)!
            
            let pin = MKPointAnnotation()
            pin.coordinate = location
            Map.addAnnotation(pin)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            
            let region = MKCoordinateRegion(center: location, span: span)
            
            Map.setRegion(region, animated:true)
            nowAnnotations.append( pin )
            for nowAnnotation in nowAnnotations { Map.addAnnotation(nowAnnotation)
            }
        }
    }
    //緯度・経度情報(GPS)が取れなかった時に動く
    func locationManager(_ manager: CLLocationManager,didFailWithError error: Error){
        print(error)
    }
    @IBAction func TrackingButton(_ sender: Any) {
        let button:UIButton = sender as! UIButton
        print(button.currentTitle)
        
        if button.currentTitle == "トラッキング開始" {
            button.setTitle("トラッキング停止", for: .normal)
            myLocationManager.startUpdatingLocation()
        }else if button.currentTitle == "トラッキング停止"{
            button.setTitle("トラッキング開始", for: .normal)
            myLocationManager.stopUpdatingLocation()
            for nowAnnotation in nowAnnotations {
                Map.removeAnnotation(nowAnnotation)
            }
            nowAnnotations = []
        }
    }
}

