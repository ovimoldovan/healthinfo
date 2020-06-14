using Microsoft.EntityFrameworkCore.Migrations;

namespace watchInfoWebApp.Migrations
{
    public partial class UpdateToDataItem : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Device",
                table: "DataItems",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ProjectId",
                table: "DataItems",
                nullable: false,
                defaultValue: 0);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Device",
                table: "DataItems");

            migrationBuilder.DropColumn(
                name: "ProjectId",
                table: "DataItems");
        }
    }
}
