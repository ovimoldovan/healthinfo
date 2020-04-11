using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;

namespace watchInfoWebApp.Tools
{
    public class ClaimsGetter
    {
        public int UserId(IEnumerable<Claim> claims)
        {
            if (claims == null)
                return -1;

            var claimId = int.Parse(
                claims
                .First(claim => claim.Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier").Value);

            return claimId;
        }

        public string UserRole(IEnumerable<Claim> claims)
        {
            if (claims == null)
                return "";

            var claimRole = claims
                .First(claim => claim.Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/role").Value;

            return claimRole;
        }
    }
}
