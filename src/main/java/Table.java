import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

@Data
public class Table {
    private String tableName;
    private List<HashMap<String,String>> columnList;

    Table(){
        this.columnList = new ArrayList<>();
    }

    @JsonProperty("name")
    private void getTableName(String name){
        this.tableName = name;
    }

    @JsonProperty("columns")
    private void getColumns(List<HashMap<String,String>> columns){
        for(HashMap<String,String> columnConfigs: columns){
            this.columnList.add(columnConfigs);
        }
    }

    String getAttributes(){
        StringBuilder attributes = new StringBuilder();
        for(HashMap<String,String> collumn:columnList){
            attributes.append(collumn.get("columnname"))
                    .append(" ")
                    .append(collumn.get("type"))
                    .append(", ");
        }
        return attributes.toString();
    }

    public String toString(){
        return "tablename: " + this.tableName + "\n"
                +"table attributes: " + this.getAttributes();
    }
}
