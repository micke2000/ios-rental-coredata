
//
//  CategoryView.swift
//  wypozyczalnia
//
//  Created by Mac2 on 16/05/2022.
//

import SwiftUI
import CoreData

struct CategoryView: View {
    @Binding var reservation:Reservation
    var category:String
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var items: FetchedResults<Items>
    
    @State var isActive:Bool
    @State var activeItem:Item
    
    init(category:String,reservation:Binding<Reservation>){
        self.category = category
        _reservation = reservation
        let predic = NSPredicate(format: "category = %@", category)
        _items = FetchRequest<Items>(sortDescriptors: [NSSortDescriptor(keyPath:     \Items.name, ascending: true)],predicate:predic)
    
        _isActive = State(initialValue: false)
        _activeItem = State(initialValue:Item(name: "", price: 0.0, image: ""))
    }
    
    var body: some View {
            VStack{
                Text("Choose a "+self.category)
                List(items){
                    item in NavigationLink(destination:ItemDetails(item:item,reservation:$reservation)){
                                HStack{
                                Text("Model: " + item.name!)
                                    Spacer()
                                Text("Price:  " + String(item.price))
                            }
                            
                            
                        }
                    
                }
            }.navigationTitle(category)
            
            
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView(category: "", reservation: .constant(Reservation(beginDate: Date(), endDate: Date(), items: [], docType: "", docNumber: "")))
    }
}
