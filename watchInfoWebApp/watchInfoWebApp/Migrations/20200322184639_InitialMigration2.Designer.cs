﻿// <auto-generated />
using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using watchInfoWebApp.Data;

namespace watchInfoWebApp.Migrations
{
    [DbContext(typeof(ApplicationDbContext))]
    [Migration("20200322184639_InitialMigration2")]
    partial class InitialMigration2
    {
        protected override void BuildTargetModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder
                .HasAnnotation("ProductVersion", "3.1.2");

            modelBuilder.Entity("watchInfoWebApp.Models.DataItem", b =>
                {
                    b.Property<long>("Id")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("INTEGER");

                    b.Property<double>("Distance")
                        .HasColumnType("REAL");

                    b.Property<string>("GpsCoordinates")
                        .HasColumnType("TEXT");

                    b.Property<int>("HeartBpm")
                        .HasColumnType("INTEGER");

                    b.Property<int>("Steps")
                        .HasColumnType("INTEGER");

                    b.Property<int?>("UserId")
                        .HasColumnType("INTEGER");

                    b.HasKey("Id");

                    b.HasIndex("UserId");

                    b.ToTable("DataItems");
                });

            modelBuilder.Entity("watchInfoWebApp.Models.User", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("INTEGER");

                    b.Property<string>("Password")
                        .HasColumnType("TEXT");

                    b.Property<string>("Username")
                        .HasColumnType("TEXT");

                    b.HasKey("Id");

                    b.ToTable("Users");
                });

            modelBuilder.Entity("watchInfoWebApp.Models.DataItem", b =>
                {
                    b.HasOne("watchInfoWebApp.Models.User", "User")
                        .WithMany()
                        .HasForeignKey("UserId");
                });
#pragma warning restore 612, 618
        }
    }
}