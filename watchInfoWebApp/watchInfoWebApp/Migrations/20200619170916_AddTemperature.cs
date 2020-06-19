using Microsoft.EntityFrameworkCore.Migrations;

namespace watchInfoWebApp.Migrations
{
    public partial class AddTemperature : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<double>(
                name: "Temperature",
                table: "DataItems",
                nullable: false,
                defaultValue: 0.0);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Temperature",
                table: "DataItems");
        }
    }
}
