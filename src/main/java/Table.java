import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Data
public class Table {
    private String tableName;
    private List<Column> columnList;

    Table(){
        this.columnList = new ArrayList<>();
    }

    @JsonProperty("tableName")
    private void getTableName(String name){
        this.tableName = name;
    }

    @JsonProperty("columns")
    private void getColumns(List<Column> columns){
        for(Column columnConfigs: columns){
            this.columnList.add(columnConfigs);
        }
    }

    String getAttributes(){
        StringBuilder attributes = new StringBuilder();
        String prefix = "";
        for(Column collumn:columnList){
            attributes.append(prefix);
            prefix = ", ";
            attributes.append(collumn.getColumnName()).append(" ");
            Map<String,Object> columnType = collumn.getType();

            //if column has complicated type we use special logic
            if (columnType.size()> 1){
                attributes.append(columnType.get("dataType").toString().replace("Type",""))
                        .append("(")
                        .append(columnType.get("size"))
                        .append(",")
                        .append(columnType.get("scale"))
                        .append(")");
            }
            else{
                attributes.append(columnType.get("dataType").toString().replace("Type",""));
            }
        }
        return attributes.toString();
    }

    public String toString(){
        return "tablename: " + this.tableName + "\n"
                +"table attributes: " + this.getAttributes();
    }
}
