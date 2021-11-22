//
//  SettingsViewController.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-10-28.
//

import UIKit
import Firebase

protocol SettingsControllerDelegate: AnyObject {
    func didSaveSettings()
}

final class SettingsViewController: UITableViewController {
    //MARK: - UI Elements
    lazy fileprivate var image1Button = createButton(selector: #selector(handleSelectPhoto))
    lazy fileprivate var image2Button = createButton(selector: #selector(handleSelectPhoto))
    lazy fileprivate var image3Button = createButton(selector: #selector(handleSelectPhoto))
    lazy fileprivate var header = UIView()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        headerSetup()
        tableViewSetup()
        fetchCurrentUser()
    }
    
    //MARK: - Initializaion
    weak var delegate: SettingsControllerDelegate?
    var user: User?
    fileprivate let activity = Helper.makeActivityAlert(message: "Saving...")
    
    override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection(FirestoreCollection.users.rawValue).document(uid).getDocument { snapShot, error in
            if let error = error {
                print("Failed to fetch current user, \(error)")
                self.present(Helper.makeErrorAlert(title: "Server Error", message: error.localizedDescription), animated: true)
                self.dismiss(animated: true)
                return
            }
            guard let userData = snapShot?.data() else { return }
            let user = User(userInfo: userData)
            self.user = user
            self.loadUsersPhotos()
            self.tableView.reloadData()
        }
    }
    
    fileprivate func loadUsersPhotos(){
        guard let user = self.user else { return }
        if let image1 = user.imageURL1 {
            self.image1Button.setImage(UIImage(named: "profilePlaceholder")?.withRenderingMode(.alwaysOriginal), for: .normal)
            ImageCacheService.shared.loadAppImage(imageURL: image1, completion: { image in
                self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            })
        }
        if let image2 = user.imageURL2 {
            self.image2Button.setImage(UIImage(named: "profilePlaceholder")?.withRenderingMode(.alwaysOriginal), for: .normal)
            ImageCacheService.shared.loadAppImage(imageURL: image2, completion: { image in
                self.image2Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            })
        }
        if let image3 = user.imageURL3 {
            self.image3Button.setImage(UIImage(named: "profilePlaceholder")?.withRenderingMode(.alwaysOriginal), for: .normal)
            ImageCacheService.shared.loadAppImage(imageURL: image3, completion: { image in
                self.image3Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            })
        }
    }
    
    //MARK: - Layout setup
    fileprivate func headerSetup(){
        header.addSubview(image1Button)
        image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: 15, left: 15, bottom: 15, right: 0))
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.5).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [image2Button, image3Button])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        header.addSubview(stackView)
        stackView.anchor(top: header.topAnchor, leading: image1Button.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: 15, left: 15, bottom: 15, right: 15))
    }
    
    fileprivate func setupNavigationBar() {
        title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
            UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(handleLogout))]
    }
    
    fileprivate func createButton(selector: Selector) -> UserImageButton {
        let button = UserImageButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 10
        return button
    }
    
    //MARK: - Fileprivates
    let dispatchGroup = DispatchGroup()
    
    fileprivate func uploadPhoto(imageData: Data, completion: @escaping (String?, Error?)->()) {
        dispatchGroup.enter()
        let fileName = UUID().uuidString
        let reference = Storage.storage().reference(withPath: "/images/\(fileName)")
        reference.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(nil, error)
                self.dispatchGroup.leave()
            }
            reference.downloadURL { url, error in
                if let error = error {
                    completion(nil, error)
                    self.dispatchGroup.leave()
                }
                completion(url?.absoluteString ?? "", nil)
                self.dispatchGroup.leave()
            }
        }
    }
    
    @objc fileprivate func handleSave() {
        present(activity, animated: true)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if image1Button.isChanged {
            if let image1 = image1Button.imageView?.image?.jpegData(compressionQuality: 0.75) {
                uploadPhoto(imageData: image1) { imageURL, error in
                    if let error = error {
                        print("Failed to upload image to firestore, \(error)")
                        self.activity.dismiss(animated: false) {
                            self.present(Helper.makeErrorAlert(title: "Registration Error", message: error.localizedDescription), animated: true)
                        }
                        return
                    }
                    if let imageURL = imageURL {
                        self.user?.imageURL1 = imageURL
                    }
                }
            }
        }
        if image2Button.isChanged {
            if let image2 = image2Button.imageView?.image?.jpegData(compressionQuality: 0.75) {
                uploadPhoto(imageData: image2) { imageURL, error in
                    if let error = error {
                        print("Failed to upload image to firestore, \(error)")
                        self.activity.dismiss(animated: false) {
                            self.present(Helper.makeErrorAlert(title: "Registration Error", message: error.localizedDescription), animated: true)
                        }
                        return
                    }
                    if let imageURL = imageURL {
                        self.user?.imageURL2 = imageURL
                    }
                }
            }
        }
        if image3Button.isChanged {
            if let image3 = image3Button.imageView?.image?.jpegData(compressionQuality: 0.75) {
                uploadPhoto(imageData: image3) { imageURL, error in
                    if let error = error {
                        print("Failed to upload image to firestore, \(error)")
                        self.activity.dismiss(animated: false) {
                            self.present(Helper.makeErrorAlert(title: "Registration Error", message: error.localizedDescription), animated: true)
                        }
                        return
                    }
                    if let imageURL = imageURL {
                        self.user?.imageURL3 = imageURL
                    }
                }
            }
        }
        
        //perform saving
        dispatchGroup.notify(queue: .main) {
            let updatedUsersData: [String: Any] = [ FirestoreKeys.uid.rawValue : self.user?.uid ?? "",
                                                    FirestoreKeys.name.rawValue : self.user?.name ?? "",
                                                    FirestoreKeys.age.rawValue : self.user?.age ?? Helper.minAge,
                                                    FirestoreKeys.bio.rawValue : self.user?.bio ?? "",
                                                    FirestoreKeys.occupation.rawValue : self.user?.occupation ?? "",
                                                    FirestoreKeys.image1.rawValue : self.user?.imageURL1 ?? "",
                                                    FirestoreKeys.image2.rawValue : self.user?.imageURL2 ?? "",
                                                    FirestoreKeys.image3.rawValue : self.user?.imageURL3 ?? "",
                                                    FirestoreKeys.minSeekAge.rawValue : self.user?.minSeekAge ?? Helper.minAge,
                                                    FirestoreKeys.maxSeekAge.rawValue : self.user?.maxSeekAge ?? Helper.maxAge
            ]
            Firestore.firestore().collection(FirestoreCollection.users.rawValue).document(uid).setData(updatedUsersData) { error in

                if let error = error {
                    print("Failed to save user's data, \(error)")
                    self.present(Helper.makeErrorAlert(title: "Saving Error", message: error.localizedDescription), animated: true)
                    return
                }
            }
            self.activity.dismiss(animated: true) {
                self.dismiss(animated: true) {
                    self.delegate?.didSaveSettings()
                }
            }
        }
    }

    //MARK: - Selectors
    @objc fileprivate func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc fileprivate func handleLogout() {
        try? Auth.auth().signOut()
        dismiss(animated: true)
    }
    
    @objc fileprivate func handleSelectPhoto(button: UserImageButton){
        let imagePicker = CustomImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.imageButton = button
        present(imagePicker, animated: true)
    }
    
    @objc fileprivate func handleMinAgeChange(slider: UISlider){
        let indexPath = IndexPath(row: 0, section: 5)
        if let ageRangeCell = tableView.cellForRow(at: indexPath) as? AgeRangeTableViewCell {
            ageRangeCell.minLabel.text = "Min \(Int(slider.value))"
            self.user?.minSeekAge = Int(slider.value)
        }
    }
    
    @objc fileprivate func handleMaxAgeChange(slider: UISlider){
        let indexPath = IndexPath(row: 0, section: 5)
        if let ageRangeCell = tableView.cellForRow(at: indexPath) as? AgeRangeTableViewCell {
            ageRangeCell.maxLabel.text = "Max \(Int(slider.value))"
            self.user?.maxSeekAge = Int(slider.value)
        }
    }
    
    @objc fileprivate func handleChangedName(textField: UITextField) {
        self.user?.name = textField.text
    }
    
    @objc fileprivate func handleChangedOccupation(textField: UITextField) {
        self.user?.occupation = textField.text
    }
    
    @objc fileprivate func handleChangedAge(textField: UITextField) {
        self.user?.age = Int(textField.text ?? "")
    }
    
    @objc fileprivate func handleChangedBio(textField: UITextField) {
        self.user?.bio = textField.text
    }
}
//MARK: - TableView setup
extension SettingsViewController {
    fileprivate func tableViewSetup() {
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 5 {
            return 90
        }
        return 45
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 5 {
            let ageRangeCell = AgeRangeTableViewCell(style: .default, reuseIdentifier: nil)
            ageRangeCell.minLabel.text = "Min \(self.user?.minSeekAge ?? Helper.minAge)"
            ageRangeCell.maxLabel.text = "Max \(self.user?.maxSeekAge ?? Helper.maxAge)"
            ageRangeCell.minSlider.value = Float(self.user?.minSeekAge ?? Helper.minAge)
            ageRangeCell.maxSlider.value = Float(self.user?.maxSeekAge ?? Helper.maxAge)
            ageRangeCell.minSlider.addTarget(self, action: #selector(handleMinAgeChange), for: .valueChanged)
            ageRangeCell.maxSlider.addTarget(self, action: #selector(handleMaxAgeChange), for: .valueChanged)
            ageRangeCell.selectionStyle = .none
            return ageRangeCell
        }
        
        let cell = SettingsTableViewCell(style: .default, reuseIdentifier: nil)
        switch indexPath.section {
        case 1:
            cell.cellTextField.placeholder = "Enter Name"
            cell.cellTextField.text = user?.name
            cell.cellTextField.addTarget(self, action: #selector(handleChangedName), for: .editingChanged)
        case 2:
            cell.cellTextField.placeholder = "Enter Occupation"
            cell.cellTextField.text = user?.occupation
            cell.cellTextField.addTarget(self, action: #selector(handleChangedOccupation), for: .editingChanged)
        case 3:
            cell.cellTextField.placeholder = "Enter Age"
            if let age = user?.age {
                cell.cellTextField.text = "\(age)"
            }
            cell.cellTextField.addTarget(self, action: #selector(handleChangedAge), for: .editingChanged)
        default:
            cell.cellTextField.placeholder = "Enter Bio"
            cell.cellTextField.text = user?.bio
            cell.cellTextField.addTarget(self, action: #selector(handleChangedBio), for: .editingChanged)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return header
        }
        let headerLabel = HeaderLabel()
        headerLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        switch section {
        case 1:
            headerLabel.text = "Name"
        case 2:
            headerLabel.text = "Occupation"
        case 3:
            headerLabel.text = "Age"
        case 4:
            headerLabel.text = "Bio"
        default:
            headerLabel.text = "Seeking Age Range"
        }
        return headerLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 300
        }
        return 40
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            return 1
        }
    }
}

//MARK: - ImagePicker
extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.editedImage] as? UIImage
        let imageButton = (picker as? CustomImagePickerController)?.imageButton
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        imageButton?.isChanged = true
        dismiss(animated: true)
    }
}

//MARK: - Custom classes
class CustomImagePickerController: UIImagePickerController {
    var imageButton: UserImageButton?
}

class UserImageButton: UIButton {
    var isChanged = false
}

class HeaderLabel: UILabel {
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: 15, dy: 0))
    }
}
