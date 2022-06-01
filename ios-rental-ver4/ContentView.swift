
//
//  ContentView.swift
//  wypozyczalnia
//
//  Created by Mac2 on 14/05/2022.
//

import SwiftUI
import CoreData

struct Item:Identifiable{
    var id = UUID()
    var name:String
    var price:Double
    var image:String
}
struct Reservation:Identifiable{
    var id = UUID()
    var beginDate:Date
    var endDate:Date
    var items:[Item]
    var docType:String
    var docNumber:String
}
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var currentReservation:Reservation = Reservation(beginDate: Date(), endDate: Date(), items: [],docType: "",docNumber: "")
    
    func onFirstRun(){
        UserDefaults.standard.set(false,forKey: "launchedBefore")
        deleteAllData("Items")
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        } else {
            print("First launch, setting UserDefault.")
            let items = [
                "Narty":[
                    Item(name: "Dlugie XXL 140", price: 43.23, image: "narty_1"),
                                                Item(name: "Krotkie M 120", price: 37.20, image: "narty_2")],
                "Buty":[
                    Item(name: "Ultra Buty", price: 33.23, image: "buty_1"),
                                                Item(name: "Slabe Buty", price: 35.20, image: "buty_2")],
                "Kije":[
                    Item(name: "Kije Samobije", price: 21.23, image: "kije_1"),
                                                Item(name: "Kije Niebije", price: 24.00, image: "kije_2")]
            ]
            for (category,items) in items{
                for item in items{
                    addItem(item: item, category: category)
                }
            }
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        
    }
    
    
    
    var body: some View {
        TabView{
            HomeView(reservation: $currentReservation)
                .tabItem{
                    Image(systemName: "house")
                    Text("Home")
                }
            Reservations()
                .tabItem {
                    Image(systemName: "clock")
                        Text("My Reservations")
                }
            CurrentReservation(reservation: $currentReservation)
                .tabItem{
                    Image(systemName: currentReservation.items.isEmpty ? "note" : "cart")
                    Text("Reservation Cart")
                }
        }.onAppear(){
            onFirstRun()
        }
    }
    func addItem(item:Item,category:String){
        let newItem = Items(context: viewContext)
        newItem.name = item.name
        newItem.price = item.price
        newItem.category = category
        newItem.image = item.image
                do {
                    try viewContext.save()
                } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError),         \(nsError.userInfo)")
        }
        
    }
    func deleteAllData(_ entity:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try viewContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                viewContext.delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
}
struct Reservations:View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Rezerwacja.beginDate, ascending: true)], animation: .default)
    private var rezerwacje:FetchedResults<Rezerwacja>
    @State var showDetails:Bool = false
    @State var reservationDetails:String = ""
    var body: some View {
        NavigationView{
            ZStack{
                Text("My Reservations")
                    .padding()
                List{
                    ForEach(rezerwacje){
                        rezerwacja in
                        VStack{
                            Text("Rezerwacja")
                            Text("Koszt: " + String(Double(round(100 * rezerwacja.totalAmount)/100)))
                        }.onTapGesture(){
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateStyle = .short
                            self.showDetails.toggle()
                            self.reservationDetails =
                        """
                        Rozpoczecie: \(dateFormatter.string(from:rezerwacja.beginDate ?? Date()))
                        Zakonczenie: \(dateFormatter.string(from:rezerwacja.endDate ?? Date()))                        Number dok: \(rezerwacja.docNumber ?? "")
                        Typ dok: \(rezerwacja.docType ?? "")
                        Koszt: \(Double(round(100 * rezerwacja.totalAmount)/100))
                        Przedmioty:
                        
                        """
                            rezerwacja.itemsArray.forEach{item in
                                self.reservationDetails = self.reservationDetails + item.name! + " Price:" + String(item.price) + "\n"
                                
                            }
                        }
                        .alert(isPresented: $showDetails){
                            Alert(title: Text("Reservation Details"), message: Text(self.reservationDetails),dismissButton: .default(Text("OK")))
                        }
                        
                    }
                }
                
            }
            .navigationTitle(Text("My Reservations"))
        }
        
    }
}
struct CurrentReservation: View {
    @Binding var reservation:Reservation
    @State var dateFormatter = DateFormatter()
    @Environment(\.managedObjectContext) private var viewContext
    @State var dataRozp = ""
    @State var dataZak = ""
    @State var duration:Int = 0
    @State var totalAmount = 0.0
    @State var showConfirmation = false
    @State var currentId = UUID()
    func setFormatter(){
        self.dateFormatter.dateStyle = .short
        self.dataRozp = dateFormatter.string(from: self.reservation.beginDate)
        self.dataZak =  dateFormatter.string(from: self.reservation.endDate)
        
        
    }
    func setTotalAmount(){
        self.totalAmount = 0.0
        self.duration = Int(((self.reservation.endDate.timeIntervalSinceReferenceDate - self.reservation.beginDate.timeIntervalSinceReferenceDate).rounded(.up) / 86400)) + 1
        self.reservation.items.forEach{
            item in
            self.totalAmount += item.price * Double(self.duration)
        }
        
    }
    var body: some View {
        NavigationView{
            ZStack{
                Text("Brak przedmiotow w rezerwacji!").opacity(self.reservation.items.isEmpty ? 1 : 0)
                VStack{
                
                Spacer()
                Text("Data rozpoczecia: " + self.dataRozp)
                Text("Data zakonczenia: " + self.dataZak)
                Text("Numer dokumentu: " + self.reservation.docNumber)
                List{
                    ForEach(self.reservation.items){
                    item in
                    HStack{
                    Text(item.name)
                        Spacer()
                    Text(String(item.price) + " per day")
                    }.onLongPressGesture(perform: {
                        self.showConfirmation.toggle()
                        self.currentId = item.id
                    })
                        
                    }
                }
                
                Button(action: {
                    self.reservation = Reservation(beginDate: Date(), endDate: Date(), items: [], docType: "", docNumber: "")
                }, label: {
                    Text("Delete")
                        .font(Font.system(size:22))
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 18).fill(Color(red:0.94,green:0.9,blue:0.84)))
                        .foregroundColor(Color.black)
                        .clipShape(Capsule())
                })
                Button(action: {
                    addReservation(reservation: self.reservation)
                    self.reservation = Reservation(beginDate: Date(), endDate: Date(), items: [], docType: "", docNumber: "")
                    
                }, label: {
                    Text("Make reservation")
                        .font(Font.system(size:22))
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 18).fill(Color(red:0.94,green:0.9,blue:0.84)))
                        .foregroundColor(Color.black)
                        .clipShape(Capsule())
                })
                Text("Calkowity koszt: " + String(Double(round(self.totalAmount * 100)/100)))
                Spacer()
            }.opacity(self.reservation.items.isEmpty ? 0 : 1)
            .alert(isPresented: $showConfirmation){
                Alert(title: Text("Removing from cart"), message: Text("Na pewno chcesz usunac przedmiot?"), primaryButton: .destructive(Text("Delete"),action: {
                    self.reservation.items = self.reservation.items.filter{
                        $0.id != currentId
                    }
                    setTotalAmount()
                }) ,secondaryButton: .default(Text("Cancel"),action: {
                    
                }))
            }
        }
            .navigationTitle("Reservation")
            .onAppear(){
                setFormatter()
                setTotalAmount()
                    
            }
        }
        
    }
    func addReservation(reservation:Reservation){
        let newRezerwacja = Rezerwacja(context: viewContext)
        newRezerwacja.beginDate = reservation.beginDate
        newRezerwacja.endDate = reservation.endDate
        newRezerwacja.totalAmount = self.totalAmount.rounded(.up)
        
        for item in reservation.items{
            
            let equipment = Equipment(context: viewContext)
            equipment.name = item.name
            equipment.price = item.price
            equipment.reservation = newRezerwacja
            
        }
        newRezerwacja.docNumber = reservation.docNumber
        newRezerwacja.docType = reservation.docType
                do {
                    try viewContext.save()
                } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError),         \(nsError.userInfo)")
        }
        
    }
}
struct HomeView: View {
    @Binding var reservation:Reservation
    @State var categories = ["Narty","Buty","Kije"]
    @State var category = "cos"
    @State var isActive = false

    var body: some View {
        NavigationView{
            VStack{
                ForEach(categories,id:\.self){c in
                    
                    NavigationLink(destination:CategoryView(category:category, reservation:$reservation),isActive:$isActive){
                            Button(action: {
                                self.category = c
                                
                                self.isActive = true
                            }, label: {
                            ZStack{
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red:0.94,green:0.9,blue:0.84))
                                    .frame(width:200,height: 100)
                                Text(c.uppercased())
                                    .font(.system(size:22,weight:.bold))
                                    .foregroundColor(Color.black)
                            }.padding(.bottom)
                                
                            })
                        }
                            
                }
                
            }
            .navigationTitle("Categories")
        }
        
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
