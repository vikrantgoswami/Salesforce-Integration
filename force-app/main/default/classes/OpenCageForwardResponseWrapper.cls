public class OpenCageForwardResponseWrapper{
	public results[] results;
	public status status;
	public Integer total_results;	//2
	public class results {
		public annotations annotations;
	}
	public class annotations {
		public DMS DMS;
	}
	public class DMS {
		public String lat;	//50° 58' 49.44000'' N
		public String lng;	//11° 19' 34.68000'' E
	}
	public class status {
		public Integer code;	//200
		public String message;	//OK
	}
}