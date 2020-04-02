import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.HashMap;
import java.util.Map;

@Data
public class Column {
    private String columnName;
    private Map<String,Object>  type;

    Column(){
        type = new HashMap<>();
    }

    @JsonProperty("columnName")
    private void getColumnName(String columnName){
        this.columnName = columnName;
    }

    @JsonProperty("type")
    private void getType(HashMap<String,Object> columnType){
        this.type.putAll(columnType);
    }
}
