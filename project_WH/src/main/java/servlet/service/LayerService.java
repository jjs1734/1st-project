package servlet.service;

import java.util.List;
import java.util.Map;

public interface LayerService {

	List<Map<String, Object>> sgg(String sd);

	List<Map<String, Object>> bjd(String sgg);

	List<Map<String, Object>> sd();

	int ele(String bjdCd);
}
