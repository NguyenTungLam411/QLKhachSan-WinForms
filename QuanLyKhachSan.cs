
using System.Data;
using System.Data.SqlClient;

public class DB
{
    public static SqlConnection GetConnection()
    {
        return new SqlConnection(
            "Data Source=.;Initial Catalog=QLKhachSan;Integrated Security=True");
    }
}

private void btnThem_Click(object sender, EventArgs e)
{
    SqlConnection conn = DB.GetConnection();
    conn.Open();

    SqlCommand cmd = new SqlCommand("sp_ThemKhach", conn);
    cmd.CommandType = CommandType.StoredProcedure;

    cmd.Parameters.AddWithValue("@CMND", txtCMND.Text);
    cmd.Parameters.AddWithValue("@HoTen", txtHoTen.Text);
    cmd.Parameters.AddWithValue("@NgaySinh", dtNgaySinh.Value);
    cmd.Parameters.AddWithValue("@DT", txtSDT.Text);
    cmd.Parameters.AddWithValue("@DC", txtDiaChi.Text);

    cmd.ExecuteNonQuery();
    conn.Close();

    MessageBox.Show("Thêm khách thành công");
}


private void btnDatPhong_Click(object sender, EventArgs e)
{
    SqlConnection conn = DB.GetConnection();
    conn.Open();

    SqlCommand cmd = new SqlCommand("sp_DatPhong", conn);
    cmd.CommandType = CommandType.StoredProcedure;

    cmd.Parameters.AddWithValue("@CMND", txtCMND.Text);
    cmd.Parameters.AddWithValue("@MaNV", txtMaNV.Text);
    cmd.Parameters.AddWithValue("@SoPhong", txtSoPhong.Text);
    cmd.Parameters.AddWithValue("@NgayDK", DateTime.Now);
    cmd.Parameters.AddWithValue("@NgayNhan", dtNhan.Value);
    cmd.Parameters.AddWithValue("@NgayTra", dtTra.Value);

    cmd.ExecuteNonQuery();
    conn.Close();

    MessageBox.Show("Đặt phòng thành công");
}



void LoadPhong()
{
    SqlConnection conn = DB.GetConnection();
    conn.Open();

    SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM tblPhong", conn);
    DataTable dt = new DataTable();
    da.Fill(dt);

    dataGridView1.DataSource = dt;

    conn.Close();
}


SELECT
    dk.MaDK,
    p.DonGia,
    DATEDIFF(DAY, dk.NgayNhan, dk.NgayTra) AS SoNgay,
    SUM(ct.SoLuong * dv.Gia) AS TienDV
FROM tblDangky dk
JOIN tblPhong p ON dk.SoPhong = p.SoPhong
LEFT JOIN tblCTDichvu ct ON dk.MaDK = ct.MaDK
LEFT JOIN tblDichvu dv ON ct.MaDV = dv.MaDV
WHERE dk.MaDK = @MaDK
GROUP BY dk.MaDK, p.DonGia, dk.NgayNhan, dk.NgayTra




private void kháchHàngToolStripMenuItem_Click(object sender, EventArgs e)
{
    new FrmKhach().Show();
}

