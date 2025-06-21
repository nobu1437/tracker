import UIKit

final class PageViewController:UIPageViewController{
    lazy var pages: [UIViewController] = {
        let first = OnboardingViewController(isFirst: true)
        let second = OnboardingViewController(isFirst: false)
        return [first, second]
    }()
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .gray
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        dataSource = self
        delegate = self
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
extension PageViewController: UIPageViewControllerDataSource{
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = pages.firstIndex(of: viewController), index + 1 < pages.count else {
                return nil
            }
            return pages[index + 1]
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = pages.firstIndex(of: viewController), index - 1 >= 0 else {
                return nil
            }
            return pages[index - 1]
        }
}
extension PageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
          
          if let currentViewController = pageViewController.viewControllers?.first,
             let currentIndex = pages.firstIndex(of: currentViewController) {
              pageControl.currentPage = currentIndex
          }
      }
}
