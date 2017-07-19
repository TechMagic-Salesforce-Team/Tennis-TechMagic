public with sharing class ImagInsertionIntoRichText {
public Document document {
    get {
      if (document == null)
        document = new Document();
      return document;
    }
    set;
  }
  
  public String imageUrl {get;set;}   
    
  public ImagInsertionIntoRichText(){
        List<Document> docs = [select Id,Name,Body from Document];
        System.debug('docs.size = '+docs.size());
        if (docs.size()>0){
            imageUrl = '/servlet/servlet.FileDownload?file='+docs.get(1).Id;
            imageUrl = 'https://c.eu11.content.force.com/servlet/servlet.FileDownload?file=0150Y000000j69B';
        } 
        //imageUrl = 'https://c.eu11.content.force.com/servlet/servlet.FileDownload?file=0150Y000000j69B';
        //imageUrl =  EncodingUtil.Base64Encode(docs.get(0).Body);
        imageUrl =  '/servlet/servlet.FileDownload?file='+docs.get(1).Id;
  }
 
  public PageReference upload() {
 
    document.AuthorId = UserInfo.getUserId();
    document.FolderId = UserInfo.getUserId(); 
    //document.Name = 'New name';
    //document.Description = 'Some desc';    
        
    try {
      insert document;
    } catch (DMLException e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'));
      return null;
    } finally {
      document.body = null; // clears the viewstate
      document = new Document();
    }
 
    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'File uploaded successfully'));
    return null;
  }
}



