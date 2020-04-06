using Microsoft.EntityFrameworkCore.Migrations;

namespace webApp.Data.Migrations
{
    public partial class AddHealthDataItem : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "HealthDataItems",
                columns: table => new
                {
                    Id = table.Column<long>(nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    UserId = table.Column<string>(nullable: true),
                    HeartBpm = table.Column<int>(nullable: false),
                    GpsCoordinates = table.Column<string>(nullable: true),
                    Steps = table.Column<int>(nullable: false),
                    Distance = table.Column<double>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_HealthDataItems", x => x.Id);
                    table.ForeignKey(
                        name: "FK_HealthDataItems_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_HealthDataItems_UserId",
                table: "HealthDataItems",
                column: "UserId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "HealthDataItems");
        }
    }
}
