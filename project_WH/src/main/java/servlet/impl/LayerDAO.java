package servlet.impl;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import egovframework.rte.psl.dataaccess.util.EgovMap;

@Repository("LayerDAO")
public class LayerDAO extends EgovComAbstractDAO {
	
	@Autowired
	private SqlSessionTemplate session;

	public List<Map<String, Object>> sd() {
		return selectList("servlet.sd");
	}

	public List<Map<String, Object>> sgg(String sd) {
		return selectList("servlet.sgg", sd);
	}

	public List<Map<String, Object>> bjd(String sgg) {
		return selectList("servlet.bjd", sgg);
	}

	public int ele(String bjdCd) {
		return selectOne("servlet.ele", bjdCd);
	}

}
