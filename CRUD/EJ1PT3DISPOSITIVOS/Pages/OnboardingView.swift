//
//  AppNavigation.swift
//  EJ1PT3DISPOSITIVOS
//
//  Created by Omar Bermejo Osuna on 09/09/25.
//



import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject private var app: AppNavigation
    
    var body: some View {
        ZStack {
            TabView(selection: $viewModel.courrentTab) {
                ForEach(viewModel.OnboardingContent.indices, id: \.self) { index in
                    let item = viewModel.OnboardingContent[index]
                    
                    ZStack {
                        Image(item.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .edgesIgnoringSafeArea(.all)
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black.opacity(0.8), .black.opacity(0.4), .clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                                .edgesIgnoringSafeArea(.all)
                            )
                        
                        VStack {
                            Spacer()
                            Text(item.title)
                                .font(.system(size: 50, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                            
                            Text(item.description)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                                .padding(.bottom, 50)
                        }
                        .padding(.bottom, 50)
                    }
                    .tag(index)
                }
            }
            .ignoresSafeArea(.all)
            .tabViewStyle(PageTabViewStyle())
          
            
            // Botón Start animado
            VStack {
                Spacer()
                Button(action: {
                    print("Se completo el OnBoarding!")
                    self.app.completeOnboarding()  // Cambiamos el estado global
                }) {
                    Image(systemName: "arrow.right")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                        .frame(width: 60, height: 60)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .padding(.bottom, 30)
                .opacity(viewModel.courrentTab == viewModel.OnboardingContent.count - 1 ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: viewModel.courrentTab)
            }
        }
    }
}
#Preview {
    OnboardingView()
        .environmentObject(AppNavigation())
}
