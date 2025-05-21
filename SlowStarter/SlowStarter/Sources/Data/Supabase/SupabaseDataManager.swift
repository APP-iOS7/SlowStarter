import Foundation
import Supabase

//TODO: 필요에 의해 변경하면 될듯

class SupabaseDataManager {
    private var client: SupabaseClient?
    private var databaseManager: DataBaseManager?
    private var storageManager: StorageManager?
    private var loginManager: LoginManager?
    
    init() {
        let supabaseURLString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
        let supabaseKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_API_KEY") as? String
        
        if let urlString = supabaseURLString,
           let url = URL(string: urlString),
           let key = supabaseKey,
           !key.isEmpty {
            client = SupabaseClient(supabaseURL: url, supabaseKey: key)
            if let client = client {
                databaseManager = DataBaseManager(client: client)
                loginManager = LoginManager(client: client)
                storageManager = StorageManager(client: client)
            }
        } else {
            client = nil
            databaseManager = nil
            loginManager = nil
            storageManager = nil
            print("Config Key is empty")
        }
    }
    
    func insertData<T>(_ data: T) -> Bool {
        
        return true
    }
    
    func fetchData<T>(_ type: T.Type) -> [T]? {
        
        return []
    }
    
    func deleteData<T>(_ data: T) -> Bool {
        
        return true
    }
    
    func updateData<T>(_ data: T) -> Bool {
        
        return true
    }
    
    func insertFile(file: Data) -> Bool {
        
        return true
    }
    
    func fetchFile(filePath: String) -> Data? {
        
        return Data()
    }
    
    func createSignedURL(filePath: String) -> URL? {
        
        return URL(string: "")
    }
}
