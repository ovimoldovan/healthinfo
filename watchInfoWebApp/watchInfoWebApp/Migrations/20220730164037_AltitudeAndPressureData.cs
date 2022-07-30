using Microsoft.EntityFrameworkCore.Migrations;

namespace watchInfoWebApp.Migrations
{
    public partial class AltitudeAndPressureData : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<double>(
                name: "AbsoluteAltitude",
                table: "DataItems",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<double>(
                name: "Pressure",
                table: "DataItems",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<double>(
                name: "RelativeAltitude",
                table: "DataItems",
                nullable: false,
                defaultValue: 0.0);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AbsoluteAltitude",
                table: "DataItems");

            migrationBuilder.DropColumn(
                name: "Pressure",
                table: "DataItems");

            migrationBuilder.DropColumn(
                name: "RelativeAltitude",
                table: "DataItems");
        }
    }
}
