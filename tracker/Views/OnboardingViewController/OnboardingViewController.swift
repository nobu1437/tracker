import UIKit

class OnboardingViewController: UIViewController{
    let isFirst: Bool
    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        return label
    }()
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    let button: UIButton = {
       let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.setTitle("Вот это технологии", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    init(isFirst: Bool) {
        self.isFirst = isFirst
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    private func setupUI(){
        backgroundImageView.image = isFirst ? .onboarding1 : .onboarding2
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        
        button.addTarget(self, action: #selector(goToNextVC), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        label.text = isFirst ? "Отслеживайте только то, что хотите" : "Даже если это не литры воды и йога"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -16),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.heightAnchor.constraint(equalToConstant: 60),
            
            label.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -160),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    @objc private func goToNextVC(){
        UserDefaults.standard.set(true, forKey: "isNotFirstLauch")
        let tabBar = UITabBarController()
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .ypWhite
        if #available(iOS 15.0, *) {
            tabBar.tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.tabBar.standardAppearance = appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16,weight: .medium),
            .foregroundColor: UIColor.black ]
        navAppearance.shadowColor = .clear
        navAppearance.backgroundColor = .ypWhite
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        let statisticVC = StatisticListViewController()
        let statisticNavVC = UINavigationController(rootViewController: statisticVC)
        statisticNavVC.tabBarItem = UITabBarItem(title: "Статистика",
                                              image: UIImage(systemName:
                                                                "hare.fill"),
                                              tag: 0)
        let trackerVC = TrackerListViewController()
        let trackerNavVC = UINavigationController(rootViewController: trackerVC)
        trackerNavVC.tabBarItem = UITabBarItem(title: "Трекеры",
                                            image: UIImage(systemName:
                                                            "record.circle.fill"),
                                            tag: 1)
        tabBar.setViewControllers([trackerNavVC,statisticNavVC], animated: true)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = tabBar
            window.makeKeyAndVisible()
        }
    }
}
