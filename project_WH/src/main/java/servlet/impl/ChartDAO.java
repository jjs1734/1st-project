package servlet.impl;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository("ChartDAO")
public class ChartDAO extends EgovComAbstractDAO {
	
	@Autowired
	private SqlSessionTemplate session;

	public int ele(String bjdCd) {
		return selectOne("servlet.ele", bjdCd);
	}

	public List<Map<String, Object>> sdChartData() {
		return selectList("servlet.sdChartData");
	}

	public List<Map<String, Object>> sggChartData(String sd) {
		return selectList("servlet.sggChartData", sd);
	}

}
