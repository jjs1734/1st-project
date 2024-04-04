package servlet.service;

import java.util.List;
import java.util.Map;

public interface ChartService {

	List<Map<String, Object>> sdChartData();

	List<Map<String, Object>> sggChartData(String sd);

}
