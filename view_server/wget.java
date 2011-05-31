import java.io.*;
import java.net.*;
import java.util.Vector;

/** This class does a simple HTTP GET and writes the retrieved content to a local file
 * 
 * @author Russ Spivey
 * @thanksTo Brian Pipa 
 * @version 1.0
 */
public class wget {

	private String myViewServerURL = "";

	public wget(String url) {
		//"http://localhost:8501/couch4cf/view_server/view_server.cfc?method=switch&returnformat=json&input="
		myViewServerURL = url;
	}

	/** This method does the actual HTTP GET call
	 * 
	 * @param data The data from CouchDB for the View Server
	 * @exception IOException 
	 */
	public void get(String data) throws IOException
	{
		try {
			data = URLEncoder.encode(data, "UTF-8");
			String theurl = myViewServerURL + data;
			URL gotoUrl = new URL(theurl);   
            
           		InputStreamReader isr = new InputStreamReader(gotoUrl.openStream());
            		BufferedReader in = new BufferedReader(isr);

            		StringBuffer sb = new StringBuffer();
            		String inputLine;
            
            		//grab the contents at the URL
            		while ((inputLine = in.readLine()) != null){
				System.out.println(inputLine);
            		}



		}
       	catch (MalformedURLException mue) {
            		mue.printStackTrace();
        	}
        	catch (IOException ioe) {
			throw ioe;
        	}
	}

	/** The main method.
	 * 
	 * @param args 
	 */
	public static void main(String[] args) {
		try {
			// setup the input buffer and output buffer
			BufferedReader stdin = new BufferedReader(new InputStreamReader(System.in));
 
			// read stdin buffer until EOF (or skip)
			while(stdin.ready()){
            			wget httpGetter = new wget(args[0]);
           			httpGetter.get(stdin.readLine());
				Thread.currentThread().sleep(1000);
			}

			stdin.close();

        	}
        	catch (Exception ex) {
			ex.printStackTrace();
        	}

	}
}