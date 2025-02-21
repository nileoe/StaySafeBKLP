import SwiftUI

struct MainTabView: View {
   @State private var selectedTab: Tab = .home
   @State private var keyboardIsVisible = false

   enum Tab {
       case home, library, map, contacts, profile
   }

   var body: some View {
       ZStack(alignment: .bottom) {
           Group {
               switch selectedTab {
               case .home:
                   HomeView()
               case .library:
                   LibraryView()
               case .map:
                   MapView()
               case .contacts:
                   ContactsView()
               case .profile:
                   ProfileView()
               }
           }
           .frame(maxWidth: .infinity, maxHeight: .infinity)
           .padding(.bottom, keyboardIsVisible ? 0 : 60)
           .background(Color.black.ignoresSafeArea())
           .navigationBarBackButtonHidden(true)

           if !keyboardIsVisible {
               tabBar
           }
       }
       .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
           withAnimation {
               keyboardIsVisible = true
           }
       }
       .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
           withAnimation {
               keyboardIsVisible = false
           }
       }
   }

   private var tabBar: some View {
       VStack {
           Spacer()
           RoundedRectangle(cornerRadius: 20)
               .fill(Color(.systemGray6).opacity(0.9))
               .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: -4)
               .frame(height: 90)
               .overlay(
                   HStack {
                       navItem(icon: "house.fill", label: "Home", tab: .home)
                       navItem(icon: "books.vertical.fill", label: "Library", tab: .library)
                       navItem(icon: "person.crop.circle.fill.fill", label: "Contacts", tab: .contacts)
                       navItem(icon: "map.fill", label: "Favorites", tab: .map)
                       navItem(icon: "person.fill", label: "Profile", tab: .profile)
                   }
                   .padding(.bottom, 20)
                   .padding(.horizontal, 10)
               )
       }
       .ignoresSafeArea(edges: .bottom)
   }

   private func navItem(icon: String, label: String, tab: Tab) -> some View {
       Button(action: {
           selectedTab = tab
       }) {
           VStack {
               Image(systemName: icon)
                   .font(.title2)
                   .foregroundColor(selectedTab == tab ? .blue : .gray)
                   .scaleEffect(selectedTab == tab ? 1.2 : 1.0)
                   .fontWeight(selectedTab == tab ? .bold : .regular)
                   .shadow(color: selectedTab == tab ? Color.blue.opacity(0.3) : Color.clear, radius: selectedTab == tab ? 10 : 0, x: 0, y: selectedTab == tab ? 5 : 0)

               Text(label)
                   .font(.footnote)
                   .foregroundColor(selectedTab == tab ? .blue : .gray)
                   .fontWeight(selectedTab == tab ? .bold : .regular)
           }
           .frame(maxWidth: .infinity)
           .animation(.easeInOut(duration: 0.2), value: selectedTab)
       }
   }
}

#Preview {
    MainTabView()
}
